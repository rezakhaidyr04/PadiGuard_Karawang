<?php
require 'db.php';

$sql = file_get_contents(__DIR__ . '/migration_v3_hama_panen.sql');

// Pisah statement by semicolon, skip yang kosong
$statements = array_filter(
    array_map('trim', explode(';', $sql)),
    fn($s) => strlen($s) > 5
);

$success = 0;
$errors  = [];

foreach ($statements as $stmt) {
    try {
        $pdo->exec($stmt);
        $success++;
    } catch (PDOException $e) {
        $errors[] = $e->getMessage();
    }
}

if (empty($errors)) {
    echo "SUCCESS: $success statement(s) dijalankan. Tabel hama_log dan panen siap!" . PHP_EOL;
} else {
    echo "Partial: $success berhasil, " . count($errors) . " error:" . PHP_EOL;
    foreach ($errors as $err) {
        echo "  - $err" . PHP_EOL;
    }
}
?>
