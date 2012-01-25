<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>DC</title>
 
<style type='text/css'>
body {
    font-family: Arial;
    font-size: 14px;
}

a {
    color: blue;
    text-decoration: none;
    font-size: 14px;
}
a:hover{text-decoration: underline;}

#container {
    width:800px;
    background:#efefef;
    border: 1px solid #ccc;
    margin:auto;
    padding:10px;
}

</style>
</head>
<body>

<div id="container">
<?php 
 $songs = "index.php/dc/songs";
 $albums = "index.php/dc/albums";
 $crud = "index.php/crud/";

?>
<a href="<?php echo base_url($songs);?>">Songs</a>&nbsp;&nbsp;&nbsp;
<a href="<?php echo base_url($albums);?>">Albums</a>&nbsp;&nbsp;&nbsp;
<a href="<?php echo base_url($crud);?>">Data CRUD (DB)</a>&nbsp;&nbsp;&nbsp;
<a href="https://github.com/bpilkerton/dylanchords">Source/DB/Parsers</a>&nbsp;&nbsp;&nbsp;
