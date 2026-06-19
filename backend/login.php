<?php
// backend/login.php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}
require_once 'db.php';

require_once 'jwt.php';

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['email']) || !isset($data['password'])) {
    echo json_encode(['status' => 'error', 'message' => 'Email dan password dibutuhkan']);
    exit;
}

$email = $data['email'];
$password = $data['password'];

try {
    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if ($user && password_verify($password, $user['password'])) {
        unset($user['password']); // Jangan kembalikan password
        
        // Buat JWT Token
        $payload = [
            'id' => $user['id'],
            'email' => $user['email']
        ];
        $token = generate_jwt($payload, $secret_key);
        
        echo json_encode([
            'status' => 'success',
            'message' => 'Login berhasil',
            'token' => $token,
            'data' => $user
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Email atau password salah']);
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Login gagal: ' . $e->getMessage()]);
}
?>
