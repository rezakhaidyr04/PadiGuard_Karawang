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
        // Ambil semua log hama milik user (boleh filter per sawah)
        if (isset($_GET['sawah_id'])) {
            $stmt = $pdo->prepare("SELECT * FROM hama_log WHERE user_id = ? AND sawah_id = ? ORDER BY detected_at DESC");
            $stmt->execute([$user_id, $_GET['sawah_id']]);
        } else {
            $stmt = $pdo->prepare("SELECT * FROM hama_log WHERE user_id = ? ORDER BY detected_at DESC");
            $stmt->execute([$user_id]);
        }
        $data = $stmt->fetchAll();
        // Decode solusi (stored as JSON string)
        foreach ($data as &$row) {
            $row['solusi'] = json_decode($row['solusi'] ?? '[]', true);
        }
        echo json_encode(['status' => 'success', 'data' => $data]);

    } elseif ($method == 'POST') {
        $data = json_decode(file_get_contents('php://input'), true);

        if (!isset($data['sawah_id']) || !isset($data['nama_hama'])) {
            echo json_encode(['status' => 'error', 'message' => 'sawah_id dan nama_hama wajib diisi']);
            exit;
        }

        $stmt = $pdo->prepare("INSERT INTO hama_log 
            (user_id, sawah_id, path_foto, url_foto, nama_hama, confidence, tingkat_risiko,
             deskripsi, solusi, pestsida_rekomendasi, dosasi_pestisida, unit_dosis,
             waktu_aplikasi, resolved, detected_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())");

        $stmt->execute([
            $user_id,
            $data['sawah_id'],
            $data['path_foto'] ?? '',
            $data['url_foto'] ?? '',
            $data['nama_hama'],
            $data['confidence'] ?? 0.0,
            $data['tingkat_risiko'] ?? 'RENDAH',
            $data['deskripsi'] ?? '',
            json_encode($data['solusi'] ?? []),
            $data['pestsida_rekomendasi'] ?? 'N/A',
            $data['dosasi_pestisida'] ?? '0',
            $data['unit_dosis'] ?? 'N/A',
            $data['waktu_aplikasi'] ?? 'N/A',
            0,
        ]);

        $newId = $pdo->lastInsertId();
        echo json_encode(['status' => 'success', 'message' => 'Log hama berhasil disimpan', 'id' => $newId]);

    } elseif ($method == 'PUT') {
        // Toggle resolved status
        $data = json_decode(file_get_contents('php://input'), true);
        if (!isset($data['id'])) {
            echo json_encode(['status' => 'error', 'message' => 'ID hama_log dibutuhkan']);
            exit;
        }

        $stmt = $pdo->prepare("UPDATE hama_log SET resolved = ?, resolved_at = ? WHERE id = ? AND user_id = ?");
        $resolved = $data['resolved'] ? 1 : 0;
        $resolvedAt = $resolved ? date('Y-m-d H:i:s') : null;
        $stmt->execute([$resolved, $resolvedAt, $data['id'], $user_id]);

        echo json_encode(['status' => 'success', 'message' => 'Status hama berhasil diupdate']);

    } elseif ($method == 'DELETE') {
        if (!isset($_GET['id'])) {
            echo json_encode(['status' => 'error', 'message' => 'ID dibutuhkan']);
            exit;
        }
        $stmt = $pdo->prepare("DELETE FROM hama_log WHERE id = ? AND user_id = ?");
        $stmt->execute([$_GET['id'], $user_id]);
        echo json_encode(['status' => 'success', 'message' => 'Log hama berhasil dihapus']);
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
