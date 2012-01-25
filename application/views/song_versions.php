<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>DC Song Versions</title>
 
<style type='text/css'>
body
{
    font-family: Arial;
    font-size: 14px;
}
a {
    color: blue;
    text-decoration: none;
    font-size: 14px;
}
a:hover
{
    text-decoration: underline;
}
</style>
</head>
<body>

    <div>
    
    <h1><?php echo $results[0]['song'];?></h1>
    
    <?php foreach ($results as $result) { ?>
        <h3><?php echo $result['song_version']; ?></h3>
        <pre><?php echo $result['song_version_content']; ?></pre>
        <hr />
    <?php } ?>
    </div>
    

</body>
</html>
