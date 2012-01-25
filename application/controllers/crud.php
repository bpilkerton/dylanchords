<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
 
class Crud extends CI_Controller {
 
    function __construct() {
        parent::__construct();
 
        /* Standard Libraries of codeigniter are required */
        $this->load->database();
        $this->load->helper('url');
        /* ------------------ */ 
        
        $this->load->library('grocery_CRUD');	
 
    }
 
    public function index() {
        $this->grocery_crud->set_table('song');
        $output = $this->grocery_crud->render();
        $this->load->view('crud/home.php',$output);
    }
 
    public function song() {
        $this->grocery_crud->set_table('song');
        $output = $this->grocery_crud->render();
        $this->load->view('crud/song_version.php',$output);
    } 
 
    public function song_version() {
        $this->grocery_crud->set_table('song_version');
        
        $this->grocery_crud->change_field_type('song_version_content','text');
        
        $output = $this->grocery_crud->render();
        $this->load->view('crud/song_version.php',$output);
    }

    public function album() {
        $this->grocery_crud->set_table('album');
        $output = $this->grocery_crud->render();
        $this->load->view('crud/song_version.php',$output);
    } 
    
    public function album_song_version() {
        $this->grocery_crud->set_table('album_song_version');
        $output = $this->grocery_crud->render();
        $this->load->view('crud/song_version.php',$output);
    } 

}
 
/* End of file main.php */
/* Location: ./application/controllers/main.php */