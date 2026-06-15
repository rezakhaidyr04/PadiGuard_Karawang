// File: firebase-functions/functions/index.js
// INSTRUKSI SETUP:
// 1. Install Firebase CLI: npm install -g firebase-tools
// 2. Init functions: firebase init functions
// 3. Pilih "Use TypeScript" (opsional, tapi recommended)
// 4. Install dependencies: cd functions && npm install
// 5. Deploy: firebase deploy --only functions

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Cloud Function untuk memprediksi risiko gagal panen
 * Dipanggil dari Flutter app dengan Riverpod
 * 
 * Input:
 * - kelembaban: double (0-100)
 * - pH: double (0-14)
 * - umurTanaman: int (hari)
 * - cuaca: string (cerah, mendung, hujan)
 * 
 * Output:
 * - risikoPersentase: int (0-100)
 * - scoreKesehatan: string (Sempurna, Baik, Cukup, Buruk)
 * - penyebab: string (penjelasan risiko)
 * - faktorKritis: string[] (daftar faktor kritis)
 * - rekomendasi: string (rekomendasi tindakan)
 */
exports.predictHarvestFailure = functions.https.onCall((data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const { kelembaban, pH, umurTanaman, cuaca } = data;

  // Input validation
  if (
    typeof kelembaban !== "number" ||
    typeof pH !== "number" ||
    typeof umurTanaman !== "number" ||
    typeof cuaca !== "string"
  ) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid input parameters"
    );
  }

  if (
    kelembaban < 0 ||
    kelembaban > 100 ||
    pH < 0 ||
    pH > 14 ||
    umurTanaman < 0
  ) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter values out of range"
    );
  }

  // Prediction logic
  const prediction = predictRisk(kelembaban, pH, umurTanaman, cuaca);

  return prediction;
});

/**
 * Algoritma prediksi risiko
 * Menggunakan simple rule-based logic (bisa diganti ML model)
 */
function predictRisk(kelembaban, pH, umurTanaman, cuaca) {
  let risikoPersentase = 0;
  const faktorKritis = [];

  // Factor 1: Kelembaban (weight: 30%)
  if (kelembaban < 30) {
    risikoPersentase += 30;
    faktorKritis.push("Kelembaban sangat rendah (<30%) - risiko kekeringan");
  } else if (kelembaban < 50) {
    risikoPersentase += 20;
    faktorKritis.push("Kelembaban rendah (50-30%) - monitor irigasi");
  } else if (kelembaban > 85) {
    risikoPersentase += 25;
    faktorKritis.push("Kelembaban tinggi (>85%) - risiko penyakit jamur");
  } else if (kelembaban > 75) {
    risikoPersentase += 10;
    faktorKritis.push("Kelembaban agak tinggi (75-85%)");
  }

  // Factor 2: pH Tanah (weight: 25%)
  if (pH < 5.0) {
    risikoPersentase += 25;
    faktorKritis.push("pH sangat rendah (<5.0) - hara tidak tersedia");
  } else if (pH < 6.0) {
    risikoPersentase += 15;
    faktorKritis.push("pH rendah (5.0-6.0) - perlu kapur");
  } else if (pH > 8.0) {
    risikoPersentase += 20;
    faktorKritis.push("pH tinggi (>8.0) - mikro nutrisi terikat");
  } else if (pH > 7.5) {
    risikoPersentase += 10;
    faktorKritis.push("pH agak tinggi (7.5-8.0)");
  }

  // Factor 3: Umur Tanaman (weight: 25%)
  if (umurTanaman >= 60 && umurTanaman <= 85) {
    risikoPersentase += 20;
    faktorKritis.push(
      `Fase berbunga (${umurTanaman} hari) - rawan penyakit & hama`
    );
  } else if (umurTanaman >= 85 && umurTanaman <= 100) {
    risikoPersentase += 15;
    faktorKritis.push(`Fase pengisian butir (${umurTanaman} hari) - kritis`);
  } else if (umurTanaman > 105) {
    risikoPersentase += 10;
    faktorKritis.push(`Tanaman terlalu matang (${umurTanaman} hari)`);
  }

  // Factor 4: Cuaca (weight: 20%)
  if (cuaca === "hujan") {
    risikoPersentase += 15;
    faktorKritis.push("Cuaca hujan - risiko penyakit menular");
  } else if (cuaca === "mendung") {
    risikoPersentase += 5;
    faktorKritis.push("Cuaca mendung - monitor intensitas cahaya");
  }

  // Clamp to 0-100
  risikoPersentase = Math.min(100, Math.max(0, risikoPersentase));

  // Determine health score
  let scoreKesehatan;
  if (risikoPersentase < 20) scoreKesehatan = "Sempurna";
  else if (risikoPersentase < 40) scoreKesehatan = "Baik";
  else if (risikoPersentase < 60) scoreKesehatan = "Cukup";
  else if (risikoPersentase < 80) scoreKesehatan = "Buruk";
  else scoreKesehatan = "Sangat Buruk";

  // Generate penyebab
  const penyebab =
    faktorKritis.length > 0
      ? faktorKritis.slice(0, 3).join("; ")
      : "Kondisi relatif normal";

  // Generate rekomendasi
  const rekomendasi = generateRecommendation(
    kelembaban,
    pH,
    umurTanaman,
    cuaca
  );

  return {
    risikoPersentase,
    scoreKesehatan,
    penyebab,
    faktorKritis,
    rekomendasi,
    timestamp: new Date().toISOString(),
  };
}

/**
 * Generate rekomendasi tindakan
 */
function generateRecommendation(kelembaban, pH, umurTanaman, cuaca) {
  const rekomendasi = [];

  if (kelembaban < 40) {
    rekomendasi.push("• Tingkatkan irigasi segera");
    rekomendasi.push("• Monitor kelembaban tanah setiap hari");
  }

  if (kelembaban > 80 || cuaca === "hujan") {
    rekomendasi.push("• Tingkatkan drainase untuk cegah busuk");
    rekomendasi.push("• Siapkan fungisida untuk aplikasi jika perlu");
  }

  if (pH < 6) {
    rekomendasi.push("• Aplikasikan kapur pertanian (CaCO3) 2-3 ton/ha");
    rekomendasi.push("• Ulangi pengapuran setiap 2-3 tahun");
  }

  if (pH > 7.5) {
    rekomendasi.push("• Aplikasikan belerang (S) 1-2 ton/ha");
    rekomendasi.push("• Tingkatkan pupuk mikro (Zn, Cu, B)");
  }

  if (umurTanaman >= 60 && umurTanaman <= 85) {
    rekomendasi.push("• Intensifkan pengamatan hama/penyakit");
    rekomendasi.push("• Penyemprotan rutin setiap 7-10 hari");
    rekomendasi.push("• Siapkan vaksinasi padi (jika tersedia)");
  }

  if (umurTanaman > 100) {
    rekomendasi.push("• Persiapkan panen");
    rekomendasi.push("• Kurangi irigasi untuk hardening");
  }

  return rekomendasi.length > 0
    ? rekomendasi.join("\\n")
    : "Lanjutkan manajemen normal. Monitor kondisi sawah secara berkala.";
}

/**
 * Scheduled function untuk update data harga gabah setiap hari
 * Integrate dengan API Hargapangan atau manual input
 */
exports.updateCropPrices = functions.pubsub
  .schedule("every day 06:00")
  .timeZone("Asia/Jakarta")
  .onRun(async (context) => {
    try {
      console.log("Updating crop prices at", new Date());

      // Fetch dari API Hargapangan.id atau sumber lain
      // const prices = await fetchPrices();

      // Mock data untuk testing
      const prices = {
        gabahKering: 5500,
        beras: 12500,
        jagung: 3900,
        kacangTanah: 12000,
      };

      // Store ke Firestore
      const db = admin.firestore();
      await db.collection("harga_komoditas").doc("terbaru").set(
        {
          ...prices,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      console.log("Crop prices updated successfully");
      return null;
    } catch (error) {
      console.error("Error updating prices:", error);
      return error;
    }
  });

/**
 * Scheduled function untuk mengirim notifikasi reminding tentang pemeliharaan
 */
exports.sendMaintenanceReminders = functions.pubsub
  .schedule("every day 07:00")
  .timeZone("Asia/Jakarta")
  .onRun(async (context) => {
    try {
      console.log("Sending maintenance reminders at", new Date());

      const db = admin.firestore();

      // Query semua sawah
      const sawahSnapshot = await db.collection("sawah").get();

      const reminders = [];

      for (const doc of sawahSnapshot.docs) {
        const sawah = doc.data();

        // Check umur tanaman
        const plantingDate = sawah.tanggalTanam.toDate();
        const ageInDays = Math.floor(
          (new Date() - plantingDate) / (1000 * 60 * 60 * 24)
        );

        if (ageInDays === 30) {
          reminders.push({
            title: "Waktu Pemupukan Pertama",
            message: `Sawah "${sawah.nama}" masuk usia 30 hari. Mulai pemupukan pertama.`,
            sawahId: doc.id,
            userId: sawah.userId,
            type: "fertilizer_reminder",
          });
        } else if (ageInDays === 60) {
          reminders.push({
            title: "Pemeriksaan Kesehatan",
            message: `Sawah "${sawah.nama}" masuk fase vegetatif. Lakukan pemeriksaan kesehatan.`,
            sawahId: doc.id,
            userId: sawah.userId,
            type: "health_check",
          });
        } else if (ageInDays === 75) {
          reminders.push({
            title: "Fase Berbunga Dimulai",
            message: `Sawah "${sawah.nama}" memasuki fase berbunga. Intensifkan pengamatan hama.`,
            sawahId: doc.id,
            userId: sawah.userId,
            type: "bloom_warning",
          });
        }
      }

      // Send notifications via FCM
      if (reminders.length > 0) {
        console.log(`Sending ${reminders.length} reminders`);
        // Implementation untuk FCM akan ditambahkan nanti
      }

      return null;
    } catch (error) {
      console.error("Error sending reminders:", error);
      return error;
    }
  });

/**
 * HTTP trigger untuk test API
 */
exports.testPrediction = functions.https.onRequest((req, res) => {
  const testData = {
    kelembaban: 65,
    pH: 6.5,
    umurTanaman: 70,
    cuaca: "cerah",
  };

  const prediction = predictRisk(
    testData.kelembaban,
    testData.pH,
    testData.umurTanaman,
    testData.cuaca
  );

  res.json({
    success: true,
    testData,
    prediction,
  });
});

// Export
console.log("Firebase Functions initialized successfully");
