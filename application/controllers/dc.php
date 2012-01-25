<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
 
class Dc extends CI_Controller {
 
    function __construct()
    {
        parent::__construct();
 
        $this->load->database();
        $this->load->helper('url');
        $this->load->model('dc_Model');
    }
 
    public function index() {
    
        $data['results'] = $this->dc_Model->get_all_songs();
    
        $this->load->view('header.php');
        $this->load->view('index.php',$data);
        $this->load->view('footer.php');        
    }
 
    public function song() {
        $song_id = $this->uri->segment(3);
        
        $summ = $this->dc_Model->get_song_summary($song_id);
        $data['song_summary'] = $summ[0]['song_summary'];
        $pre = $this->dc_Model->get_song_preamble($song_id);
        $data['song_preamble'] = $pre[0]['song_preamble'];
        $data['results'] = $this->dc_Model->get_song_versions($song_id);
        
        $this->load->view('header.php');
        $this->load->view('song.php',$data);
        $this->load->view('footer.php');
    } 
 
    #copypasta index()
    public function songs() {
        $data['results'] = $this->dc_Model->get_all_songs();
        $this->load->view('header.php');
        $this->load->view('index.php',$data);
        $this->load->view('footer.php');        
    }
 
    public function song_versions() {
        $song_id = $this->uri->segment(3);
        $data['results'] = $this->dc_Model->get_song_versions($song_id);

        $this->load->view('header.php');
        $this->load->view('song_versions.php',$data);
        $this->load->view('footer.php');
    }

    public function albums() {
        $data['results'] = $this->dc_Model->get_albums();

        $this->load->view('header.php');
        $this->load->view('albums.php',$data);
        $this->load->view('footer.php');
    }
    
    public function album() {
        $album_id = $this->uri->segment(3);
        
        $album_name = $this->dc_Model->get_album_name($album_id);
        $data['album_name'] = $album_name[0]['album_name'];
        $notes = $this->dc_Model->get_album_notes($album_id);
        $data['album_notes'] = $notes[0]['album_notes'];
        $data['results'] = $this->dc_Model->get_album($album_id);

        $this->load->view('header.php');
        $this->load->view('album.php', $data);
        $this->load->view('footer.php');
    }

}
 
/* End of file main.php */
/* Location: ./application/controllers/main.php */