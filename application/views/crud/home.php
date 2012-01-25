<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>CRUD Home Remote from git l33ter</title>
 
<?php 
foreach($css_files as $file): ?>
    <link type="text/css" rel="stylesheet" href="<?php echo $file; ?>" />
 
<?php endforeach; ?>
<?php foreach($js_files as $file): ?>
 
    <script src="<?php echo $file; ?>"></script>
<?php endforeach; ?>
 
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
<!-- Beginning header -->
    <div>
        <a href='<?php echo site_url('crud/song')?>'>Song</a> | 
        <a href='<?php echo site_url('crud/song_version')?>'>Song Version</a> | 
        <a href='<?php echo site_url('crud/album')?>'>Albums</a> |
        <a href='<?php echo site_url('crud/album_song_version')?>'>Album Song Version</a> |
    </div>
<!-- End of header-->
    <div style='height:20px;'></div>  
    <div>
        <?php echo $output; ?>
 
    </div>
<!-- Beginning footer -->
<div>Footer</div>
<!-- End of Footer -->
</body>
</html>
