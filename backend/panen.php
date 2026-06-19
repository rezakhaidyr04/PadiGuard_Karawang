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
        if (isset($_GET['sawah_id'])) {
            $stmt = $pdo->prepare("SELECT * FROM panen WHERE user_id = ? AND sawah_id = ? ORDER BY tanggal_panen DESC");
            $stmt->execute([$user_id, $_GET['sawah_id']]);
        } else {
            $stmt = $pdo->prepare("SELECT * FROM panen WHERE user_id = ? ORDER BY tanggal_panen DESC");
            $stmt->execute([$user_id]);
        }
        $data = $stmt->fetchAll();
        echo json_encode(['status' => 'success', 'data' => $data]);

    } elseif ($method == 'POST') {
        $data = json_decode(file_get_contents('php://input'), true);

        if (!isset($data['sawah_id']) || !isset($data['hasil_panen_kg'])) {
            echo json_encode(['status' => 'error', 'message' => 'sawah_id dan hasil_panen_kg wajib diisi']);
            exit;
        }

        $hasilKg      = (float) $data['hasil_panen_kg'];
        $luasHektar   = (float) ($data['luas_hektar'] ?? 1.0);
        $hasilPerHa   = $luasHektar > 0 ? round($hasilKg / $luasHektar, 2) : 0;
        $hargaPerKg   = (float) ($data['harga_jual_per_kg'] ?? 6500);
        $totalNilai   = round($hasilKg * $hargaPerKg);

        $stmt = $pdo->prepare("INSERT INTO panen 
            (user_id, sawah_id, tanggal_panen, hasil_panen_kg, hasil_per_hektar,
             luas_hektar, kualitas_gabah, kadar_air, harga_jual_per_kg,
             total_nilai_panen, catatan, metode_panen)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        $stmt->execute([
            $user_id,
            $data['sawah_id'],
            $data['tanggal_panen'] ?? date('Y-m-d'),
            $hasilKg,
            $hasilPerHa,
            $luasHektar,
            $data['kualitas_gabah'] ?? 'GKP',
            $data['kadar_air'] ?? 25.0,
            $hargaPerKg,
            $totalNilai,
            $data['catatan'] ?? '',
            $data['metode_panen'] ?? 'manual',
        ]);

        $newId = $pdo->lastInsertId();

        // Update status sawah jadi 'panen'
        $stmtUpdate = $pdo->prepare("UPDATE sawah SET status = 'panen', updated_at = NOW() WHERE id = ? AND user_id = ?");
        $stmtUpdate->execute([$data['sawah_id'], $user_id]);

        echo json_encode([
            'status'          => 'success',
            'message'         => 'Data panen berhasil disimpan',
            'id'              => $newId,
            'hasil_per_ha'    => $hasilPerHa,
            'total_nilai'     => $totalNilai,
        ]);

    } elseif ($method == 'PUT') {
        $data = json_decode(file_get_contents('php://input'), true);
        if (!isset($data['id'])) {
            echo json_encode(['status' => 'error', 'message' => 'ID panen dibutuhkan']);
            exit;
        }

        $stmt = $pdo->prepare("UPDATE panen SET
            tanggal_panen     = ?,
            hasil_panen_kg    = ?,
            kualitas_gabah    = ?,
            kadar_air         = ?,
            harga_jual_per_kg = ?,
            catatan           = ?
            WHERE id = ? AND user_id = ?");

        $stmt->execute([
            $data['tanggal_panen'] ?? date('Y-m-d'),
            $data['hasil_panen_kg'],
            $data['kualitas_gabah'] ?? 'GKP',
            $data['kadar_air'] ?? 25.0,
            $data['harga_jual_per_kg'] ?? 6500,
            $data['catatan'] ?? '',
            $data['id'],
            $user_id,
        ]);

        echo json_encode(['status' => 'success', 'message' => 'Data panen berhasil diupdate']);

    } elseif ($method == 'DELETE') {
        if (!isset($_GET['id'])) {
            echo json_encode(['status' => 'error', 'message' => 'ID dibutuhkan']);
            exit;
        }
        $stmt = $pdo->prepare("DELETE FROM panen WHERE id = ? AND user_id = ?");
        $stmt->execute([$_GET['id'], $user_id]);
        echo json_encode(['status' => 'success', 'message' => 'Data panen berhasil dihapus']);
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
