USE padiguard_db;

CREATE TABLE IF NOT EXISTS sawah (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    nama VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8) DEFAULT 0.0,
    longitude DECIMAL(11, 8) DEFAULT 0.0,
    luas_hektar DECIMAL(10, 2) DEFAULT 0.0,
    jenis_tanaman VARCHAR(50) DEFAULT 'padi',
    tanggal_tanam DATE,
    tanggal_panen_expected DATE,
    umur_tanaman_hari INT DEFAULT 0,
    kelembaban DECIMAL(5, 2) DEFAULT 0.0,
    ph DECIMAL(4, 2) DEFAULT 7.0,
    temperature_celsius DECIMAL(5, 2) DEFAULT 25.0,
    jenis_air_tanah VARCHAR(50) DEFAULT 'liat',
    ketersediaan_air VARCHAR(50) DEFAULT 'lancar',
    status VARCHAR(50) DEFAULT 'tanam',
    status_kesehatan VARCHAR(50) DEFAULT 'sehat',
    skor_risiko INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
