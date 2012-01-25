    <h1><?php echo $results[0]['song'];?></h1>

    <div id="songs">
        <ul>
        <?php $n = 0; foreach ($results as $result) { ?>
            <li><a href="#v<?php echo $n;?>"><?php echo $result['song_version']; ?></a></li>
        <?php $n++;} ?>
        </ul>
    </div>
    
    <?php if (isset($song_summary)) { ?>
    <div id="summary">
        <h3>Summary</h3>
        <p><?php echo $song_summary;?></p>
    </div>
    <?php }?>
        
    <?php if (isset($song_preamble)) { ?>
    <div id="preamble">
        <h3>Preamble</h3>
        <p><?php echo $song_preamble;?></p>
    </div>
        <?php }?>
    
    
    
    <?php $n = 0; foreach ($results as $result) { ?>
        <div class="song_version">
            <a name="v<?php echo $n; ?>"></a>
            <h3><?php echo $result['song_version']; ?></h3>
            <pre><?php echo $result['song_version_content']; ?></pre>
            <hr />
        </div>
    <?php $n++;} ?>
