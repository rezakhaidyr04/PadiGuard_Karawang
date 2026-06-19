-- ============================================================
-- PadiGuard Karawang — Database Migration v3
-- Buat tabel hama_log dan panen
-- Jalankan di phpMyAdmin -> tab SQL
-- ============================================================

-- Tabel log deteksi hama
CREATE TABLE IF NOT EXISTS `hama_log` (
  `id`                    INT AUTO_INCREMENT PRIMARY KEY,
  `user_id`               INT NOT NULL,
  `sawah_id`              INT NOT NULL,
  `path_foto`             VARCHAR(255) DEFAULT '',
  `url_foto`              TEXT,
  `nama_hama`             VARCHAR(150) NOT NULL,
  `confidence`            FLOAT DEFAULT 0.0,
  `tingkat_risiko`        ENUM('RENDAH','SEDANG','TINGGI') DEFAULT 'RENDAH',
  `deskripsi`             TEXT,
  `solusi`                TEXT COMMENT 'Array solusi disimpan sebagai JSON string',
  `pestsida_rekomendasi`  VARCHAR(150) DEFAULT 'N/A',
  `dosasi_pestisida`      VARCHAR(50) DEFAULT '0',
  `unit_dosis`            VARCHAR(30) DEFAULT 'N/A',
  `waktu_aplikasi`        VARCHAR(100) DEFAULT 'N/A',
  `resolved`              TINYINT(1) DEFAULT 0,
  `resolved_at`           DATETIME DEFAULT NULL,
  `detected_at`           DATETIME DEFAULT CURRENT_TIMESTAMP,
  `created_at`            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at`            TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`sawah_id`) REFERENCES `sawah`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabel catatan hasil panen
CREATE TABLE IF NOT EXISTS `panen` (
  `id`                  INT AUTO_INCREMENT PRIMARY KEY,
  `user_id`             INT NOT NULL,
  `sawah_id`            INT NOT NULL,
  `tanggal_panen`       DATE NOT NULL,
  `hasil_panen_kg`      FLOAT DEFAULT 0.0 COMMENT 'Total berat gabah kg',
  `hasil_per_hektar`    FLOAT DEFAULT 0.0 COMMENT 'kg/ha, dihitung otomatis backend',
  `luas_hektar`         FLOAT DEFAULT 1.0,
  `kualitas_gabah`      ENUM('GKP','GKG','Premium') DEFAULT 'GKP' COMMENT 'GKP=Kering Panen, GKG=Kering Giling',
  `kadar_air`           FLOAT DEFAULT 25.0 COMMENT 'Persen kadar air saat panen',
  `harga_jual_per_kg`   INT DEFAULT 6500 COMMENT 'Rupiah per kg',
  `total_nilai_panen`   BIGINT DEFAULT 0 COMMENT 'Rupiah total hasil jual',
  `catatan`             TEXT,
  `metode_panen`        ENUM('manual','combine_harvester') DEFAULT 'manual',
  `created_at`          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at`          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`sawah_id`) REFERENCES `sawah`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
