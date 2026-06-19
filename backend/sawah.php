<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

require_once 'db.php';
require_once 'jwt.php';

$token = get_bearer_token();
if (!$token) {
    echo json_encode(['status' => 'error', 'message' => 'Token tidak ditemukan']);
    exit;
}

$userData = verify_jwt($token, $secret_key);
if (!$userData) {
    echo json_encode(['status' => 'error', 'message' => 'Token tidak valid atau kadaluarsa']);
    exit;
}

$user_id = $userData['id'];
$method = $_SERVER['REQUEST_METHOD'];

try {
    if ($method == 'GET') {
        // Ambil data sawah
        $stmt = $pdo->prepare("SELECT * FROM sawah WHERE user_id = ? ORDER BY created_at DESC");
        $stmt->execute([$user_id]);
        $sawah = $stmt->fetchAll();
        echo json_encode(['status' => 'success', 'data' => $sawah]);
        
    } elseif ($method == 'POST') {
        // Tambah sawah baru
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (!isset($data['nama']) || !isset($data['luas_hektar'])) {
            echo json_encode(['status' => 'error', 'message' => 'Nama dan Luas Hektar wajib diisi']);
            exit;
        }

        $stmt = $pdo->prepare("INSERT INTO sawah 
            (user_id, nama, latitude, longitude, luas_hektar, jenis_tanaman, tanggal_tanam, tanggal_panen_expected, umur_tanaman_hari, kelembaban, ph, temperature_celsius, jenis_air_tanah, ketersediaan_air, status, status_kesehatan, skor_risiko) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            
        $stmt->execute([
            $user_id,
            $data['nama'],
            $data['latitude'] ?? 0.0,
            $data['longitude'] ?? 0.0,
            $data['luas_hektar'],
            $data['jenis_tanaman'] ?? 'padi',
            $data['tanggal_tanam'] ?? date('Y-m-d'),
            $data['tanggal_panen_expected'] ?? date('Y-m-d', strtotime('+120 days')),
            $data['umur_tanaman_hari'] ?? 0,
            $data['kelembaban'] ?? 0.0,
            $data['ph'] ?? 7.0,
            $data['temperature_celsius'] ?? 25.0,
            $data['jenis_air_tanah'] ?? 'liat',
            $data['ketersediaan_air'] ?? 'lancar',
            $data['status'] ?? 'tanam',
            $data['status_kesehatan'] ?? 'sehat',
            $data['skor_risiko'] ?? 0
        ]);
        
        $newId = $pdo->lastInsertId();
        echo json_encode(['status' => 'success', 'message' => 'Sawah berhasil ditambahkan', 'id' => $newId]);
        
    } elseif ($method == 'PUT') {
        // Update sawah
        $data = json_decode(file_get_contents('php://input'), true);
        if (!isset($data['id'])) {
            echo json_encode(['status' => 'error', 'message' => 'ID Sawah dibutuhkan']);
            exit;
        }
        
        $stmt = $pdo->prepare("UPDATE sawah SET nama=?, luas_hektar=?, jenis_tanaman=?, status=?, status_kesehatan=?, skor_risiko=? WHERE id=? AND user_id=?");
        $stmt->execute([
            $data['nama'],
            $data['luas_hektar'],
            $data['jenis_tanaman'] ?? 'padi',
            $data['status'] ?? 'tanam',
            $data['status_kesehatan'] ?? 'sehat',
            $data['skor_risiko'] ?? 0,
            $data['id'],
            $user_id
        ]);
        
        echo json_encode(['status' => 'success', 'message' => 'Sawah berhasil diupdate']);
        
    } elseif ($method == 'DELETE') {
        // Hapus sawah
        if (!isset($_GET['id'])) {
            echo json_encode(['status' => 'error', 'message' => 'ID Sawah dibutuhkan']);
            exit;
        }
        $stmt = $pdo->prepare("DELETE FROM sawah WHERE id = ? AND user_id = ?");
        $stmt->execute([$_GET['id'], $user_id]);
        
        echo json_encode(['status' => 'success', 'message' => 'Sawah berhasil dihapus']);
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
