<?php
// backend/register.php
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

if (!isset($data['name']) || !isset($data['email']) || !isset($data['password'])) {
    echo json_encode(['status' => 'error', 'message' => 'Lengkapi semua data']);
    exit;
}

$name = $data['name'];
$email = $data['email'];
$password = password_hash($data['password'], PASSWORD_BCRYPT);

try {
    $stmt = $pdo->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
    $stmt->execute([$name, $email, $password]);
    $newUserId = $pdo->lastInsertId();
    
    // Buat JWT Token
    $payload = [
        'id' => $newUserId,
        'email' => $email
    ];
    $token = generate_jwt($payload, $secret_key);
    
    echo json_encode([
        'status' => 'success', 
        'message' => 'Registrasi berhasil',
        'token' => $token,
        'data' => [
            'id' => $newUserId,
            'name' => $name,
            'email' => $email
        ]
    ]);
} catch (PDOException $e) {
    if ($e->getCode() == 23000) { // Constraint violation (Duplicate entry)
        echo json_encode(['status' => 'error', 'message' => 'Email sudah terdaftar']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Registrasi gagal: ' . $e->getMessage()]);
    }
}
?>
