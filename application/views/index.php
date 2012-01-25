
    <div>
    <ul>
        <?php foreach ($results as $result) { ?>
            <li><a href="<?php echo base_url("index.php/dc/song/" . $result['id']);?>"><?php echo $result['song'];?></a></li>
        <?php } ?>
    </ul>
    </div>