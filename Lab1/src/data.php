<?php
session_start();

if (!isset($_SESSION['students'])) {
    $_SESSION['students'] = [];
}

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['action']) && $_POST['action'] == "save") {
    $name = htmlspecialchars($_POST['name']);
    $age = htmlspecialchars($_POST['age']);
    $id = isset($_POST['id']) ? $_POST['id'] : null;

    if (!empty($name) && !empty($age)) {
        if ($id === null || $id === "") { 

            $_SESSION['students'][] = ["id" => uniqid(), "name" => $name, "age" => $age];
        } else {
            foreach ($_SESSION['students'] as &$student) {
                if ($student['id'] == $id) {
                    $student['name'] = $name;
                    $student['age'] = $age;
                    break;
                }
            }
        }
    }
    exit;
}

if (isset($_GET['action']) && $_GET['action'] == "list") {
    $output = "";
    foreach ($_SESSION['students'] as $student) {
        $output .= "<tr>
            <td>{$student['name']}</td>
            <td>{$student['age']}</td>
            <td>
                <button class='edit' data-id='{$student['id']}'>Edit</button>
                <button class='delete' data-id='{$student['id']}'>Delete</button>
            </td>
        </tr>";
    }
    echo $output;
    exit;
}

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['action']) && $_POST['action'] == "delete") {
    $id = $_POST['id'];
    $_SESSION['students'] = array_filter($_SESSION['students'], function ($student) use ($id) {
        return $student['id'] !== $id;
    });
    exit;
}

if (isset($_GET['action']) && $_GET['action'] == "get" && isset($_GET['id'])) {
    foreach ($_SESSION['students'] as $student) {
        if ($student['id'] == $_GET['id']) {
            echo json_encode($student);
            exit;
        }
    }
}

?>
