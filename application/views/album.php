    <h1><?php echo $album_name;?></h1>
    <p><?php echo $album_notes;?></p>
    
    <ul>
    <?php foreach ($results as $result) { ?>
        <?php $link = "index.php/dc/song/" . $result['id'];?>
        <li><a href="<?php echo base_url($link);?>"><?php echo $result['song']; ?></li>
    <?php } ?>
    </ul>
