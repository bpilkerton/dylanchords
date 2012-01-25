    <ul>
    <?php foreach ($results as $result) { ?>
        <?php $link = "index.php/dc/album/" . $result['id'];?>
        <li><a href="<?php echo base_url($link);?>"><?php echo $result['album_name']; ?></li>
    <?php } ?>
    </ul>
