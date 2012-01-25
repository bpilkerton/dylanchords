<?php
class dc_Model  extends CI_Model  {
    
	function __construct() {
        parent::__construct();
        $this->load->database();
    }

    function get_albums() {
        $sql = "SELECT * FROM album;";
        $query = $this->db->query($sql);
        
        $result = Array();
        foreach ($query->result_array() as $row) {
            array_push($result,$row);
        }
        
    	return $result;
    }
    
    function get_album($album_id = NULL) {
        $sql = "SELECT DISTINCT song.id,song.song,song_version.song_version ";
        $sql .= "FROM song JOIN album_song_version ON album_song_version.song_id = song.id ";
        $sql .= "JOIN song_version ON song_version.song = album_song_version.song_id ";
        $sql .= "WHERE album_song_version.album = " . $album_id . " AND song_version.song_version= 'Album Version'";
        
        $query = $this->db->query($sql);
        $result = Array();
        foreach ($query->result_array() as $row) {
            array_push($result,$row);
        }
        
    	return $result;
    }
    
    function get_album_notes($album_id = NULL) {
        $sql = "SELECT album_notes FROM album WHERE id=" . $album_id;
        $query = $this->db->query($sql);
        
    	return $query->result_array();    
    }
    
    function get_album_name($album_id = NULL) {
        $sql = "SELECT album_name FROM album WHERE id=" . $album_id;
        $query = $this->db->query($sql);
        
    	return $query->result_array();
    }
    
    function get_song_versions($id = NULL) {
        $sql = "SELECT song.song,song_version.song_version,song_version.song_version_content ";
        $sql .= "FROM song ";
        $sql .= "JOIN song_version on song.id=song_version.song ";
        $sql .= "WHERE song.id=" . $id . ";";

        $query = $this->db->query($sql);
        $result = Array();
        foreach ($query->result_array() as $row) {
            array_push($result,$row);
        }
        
    	return $result;
        
    }
    
    function get_song_summary($id = NULL) {
        $sql = "SELECT song.song_summary ";
        $sql .= "FROM song ";
        $sql .= "WHERE song.id=" . $id . ";";
        $query = $this->db->query($sql);

        return $query->result_array();
        
    }

    function get_song_preamble($id = NULL) {
        $sql = "SELECT song.song_preamble ";
        $sql .= "FROM song ";
        $sql .= "WHERE song.id=" . $id . ";";
        $query = $this->db->query($sql);
        
        return $query->result_array();
        
    }    
    
    function get_all_songs($id = NULL) {
        $sql = "SELECT id,song FROM song ORDER BY song ASC;";
        
        $query = $this->db->query($sql);
        $result = Array();
        foreach ($query->result_array() as $row) {
            array_push($result,$row);
        }
        
    	return $result;
    }
    

}