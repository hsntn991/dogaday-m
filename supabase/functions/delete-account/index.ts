import { createClient } from "https://esm.sh/@supabase/supabase-js@2.48.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

/**
 * Belirtilen klasör prefix'i altındaki tüm dosyaları klasör derinliğinden bağımsız
 * ve sayfalama (pagination) sınırlarına takılmadan güvenle listeler.
 */
async function collectAllFilePaths(
  adminClient: ReturnType<typeof createClient>,
  bucket: string,
  rootPrefix: string,
): Promise<string[]> {
  const filePaths: string[] = [];
  const folderQueue: string[] = [rootPrefix];
  const PAGE_SIZE = 100;

  while (folderQueue.length > 0) {
    const currentFolder = folderQueue.shift()!;
    let offset = 0;

    while (true) {
      const { data: items, error } = await adminClient.storage
        .from(bucket)
        .list(currentFolder, {
          limit: PAGE_SIZE,
          offset: offset,
          sortBy: { column: "name", order: "asc" },
        });

      if (error) {
        throw new Error(
          `Storage listeleme hatası [${currentFolder}]: ${error.message}`,
        );
      }

      if (!items || items.length === 0) {
        break;
      }

      for (const item of items) {
        // Supabase Storage sanal klasör tespiti: id veya metadata null ise klasördür
        const isFolder = item.id === null || item.metadata === null;
        const fullPath = `${currentFolder}/${item.name}`;

        if (isFolder) {
          folderQueue.push(fullPath);
        } else {
          filePaths.push(fullPath);
        }
      }

      // Sayfadaki eleman sayısı PAGE_SIZE'dan azsa bu klasörün tamamı taranmıştır
      if (items.length < PAGE_SIZE) {
        break;
      }

      offset += PAGE_SIZE;
    }
  }

  return filePaths;
}

/**
 * Toplanan dosya yollarını Supabase / S3 toplu silme sınırlarına uygun olarak
 * 100'lük parçalar (batch) halinde siler.
 */
async function deleteAllFiles(
  adminClient: ReturnType<typeof createClient>,
  bucket: string,
  filePaths: string[],
): Promise<void> {
  const BATCH_SIZE = 100;

  for (let i = 0; i < filePaths.length; i += BATCH_SIZE) {
    const batch = filePaths.slice(i, i + BATCH_SIZE);
    const { error } = await adminClient.storage.from(bucket).remove(batch);

    if (error) {
      throw new Error(`Storage dosya silme hatası: ${error.message}`);
    }
  }
}

Deno.serve(async (req: Request) => {
  // CORS ön uçuş (preflight) kontrolü
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Yalnızca POST istekleri kabul edilir." }),
      {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  try {
    // 1. Yetkilendirme başlığını al
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({
          error: "Yetkilendirme başlığı (Authorization: Bearer <token>) eksik.",
        }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // 2. Sunucu ortam değişkenlerini doğrula
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey) {
      return new Response(
        JSON.stringify({ error: "Sunucu ortam yapılandırması eksik." }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // 3. Kullanıcı JWT'sini sunucu tarafında doğrula
    // İstemciden asla user_id parametresi kabul edilmez; kimlik yalnızca doğrulanmış JWT'den alınır.
    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false },
    });

    const {
      data: { user },
      error: authError,
    } = await userClient.auth.getUser();

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Geçersiz veya süresi dolmuş oturum." }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const userId = user.id;

    // 4. Admin client oluştur (yalnızca sunucu içinde izole kullanılır)
    const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    // A. Storage temizliği: kullanıcıya ait özel bucket'lardaki tüm dosyaları
    // iç içe klasör derinliğinden bağımsız ve sayfalama sınırlarına takılmadan tespit et ve sil.
    // KRİTİK GÜVENLİK KURALI: Storage temizliği eksiksiz tamamlanmadan auth.admin.deleteUser ÇALIŞMAMALIDIR.
    try {
      const privateUserBuckets = ["place-submissions", "community-photos"];
      for (const bucket of privateUserBuckets) {
        const filesToDelete = await collectAllFilePaths(
          adminClient,
          bucket,
          userId,
        );

        if (filesToDelete.length > 0) {
          await deleteAllFiles(adminClient, bucket, filesToDelete);
        }
      }
    } catch (storageError) {
      console.error(
        "Storage temizliği başarısız oldu, hesap silme durduruldu:",
        storageError instanceof Error ? storageError.message : "Bilinmeyen hata",
      );
      return new Response(
        JSON.stringify({
          error:
            "Depolama alanındaki kullanıcı dosyaları temizlenemediği için hesap silme işlemi durduruldu.",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // B. Denetim günlüğünde aktör kaydı varsa güvenle null yap (anonimleştir)
    try {
      await adminClient
        .from("moderation_audit_logs")
        .update({ actor_id: null })
        .eq("actor_id", userId);
    } catch {
      // SET NULL migration'ı veri tabanı seviyesinde güvence sağlar
    }

    // C. Kullanıcı hesabını Supabase Admin API ile sil
    // (place_submissions ve app_user_roles tabloları ON DELETE CASCADE ile otomatik silinir)
    const { error: deleteUserError } =
      await adminClient.auth.admin.deleteUser(userId);

    if (deleteUserError) {
      console.error("Kullanıcı silinemedi");
      return new Response(
        JSON.stringify({ error: "Hesap silme işlemi tamamlanamadı." }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Başarılı yanıt
    return new Response(
      JSON.stringify({
        success: true,
        message: "Hesap ve ilişkili tüm veriler kalıcı olarak silindi.",
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch {
    return new Response(
      JSON.stringify({ error: "İşlem sırasında beklenmeyen bir hata oluştu." }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
