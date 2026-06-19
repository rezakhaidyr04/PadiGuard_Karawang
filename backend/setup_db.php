<?php
require_once 'db.php';

$sql = file_get_contents('database.sql');

try {
    $pdo->exec($sql);
    echo "Tabel berhasil dibuat di database padiguard_db!\n";
} catch (PDOException $e) {
    echo "Gagal membuat tabel: " . $e->getMessage() . "\n";
}
?>
