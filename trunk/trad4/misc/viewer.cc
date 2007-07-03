
// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE


#include <gtkmm.h>
#include <iostream>
#include <vector>
#include <map>
#include <sstream>
#include <fstream>
#include <sys/shm.h>

using namespace std;

#include "../objects/trad4.h"

#include "time.h"

class ObjectViewer : public Gtk::Window
{

public:

    ObjectViewer();
    virtual ~ObjectViewer();

protected:

    bool Refresh( int num );

    class ModelColumns : public Gtk::TreeModel::ColumnRecord
    {
        public:

        ModelColumns()
        {
            add(_col_id);
            add(_col_type);
            add(_col_name);
            add(_col_status);
            add(_col_sleep_time);
            add(_col_last_published);
            add(_col_shmid);
            add(_col_pid);
        }

        Gtk::TreeModelColumn<int> _col_id;
        Gtk::TreeModelColumn<Glib::ustring> _col_type;
        Gtk::TreeModelColumn<Glib::ustring> _col_name;
        Gtk::TreeModelColumn<Glib::ustring> _col_status;
        Gtk::TreeModelColumn<int> _col_sleep_time;
        Gtk::TreeModelColumn<Glib::ustring> _col_last_published;
        Gtk::TreeModelColumn<int> _col_shmid;
        Gtk::TreeModelColumn<int> _col_pid;
    };

    ModelColumns _columns;

    Gtk::VBox _vBox;

    Gtk::ScrolledWindow _scrolledWindow;
    Gtk::TreeView _treeView;
    Glib::RefPtr<Gtk::ListStore> _refTreeModel;

    vector<Gtk::TreeModel::Row> my_rows;
    vector<Glib::ustring> _status_vec;
    std::map<int, Glib::ustring> _type_map;
    object_header* _object_headers[MAX_OBJECTS];

    obj_loc* _obj_loc;

    std::string TimeToString( time_t time );
};


ObjectViewer::ObjectViewer()
{
    set_title("ObjectViewer");
    set_border_width(5);
    set_default_size(650, 400);

    add(_vBox);

    sigc::slot<bool> my_slot = sigc::bind(sigc::mem_fun(*this, &ObjectViewer::Refresh), 0);

    sigc::connection conn = Glib::signal_timeout().connect(my_slot, 1000);

    _scrolledWindow.add(_treeView);

    _scrolledWindow.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC);

    _vBox.pack_start(_scrolledWindow);


    _refTreeModel = Gtk::ListStore::create(_columns);
    _treeView.set_model(_refTreeModel);

    Gtk::TreeModel::Row row;

    char* obj_loc_file_name = getenv( "OBJ_LOC_FILE" );

    if ( obj_loc_file_name == NULL )
    {
        cout << "OBJ_LOC_FILE not set. Exiting" << endl;
        exit(1);
    }

    fstream obj_loc_file(obj_loc_file_name, ios::in);

    if ( ! obj_loc_file.is_open() )
    {
        cout << "obj_loc not running. Exiting." << endl;
        exit (1);
    }

    char shmid_char[OBJ_LOC_SHMID_LEN];

    obj_loc_file >> shmid_char;

    cout << "Attaching to obj_loc shmid: " << shmid_char << endl;

    int shmid = atoi(shmid_char);

    obj_loc_file.close();

    void* shm;

    if ((shm = shmat(shmid, NULL, SHM_RDONLY)) == (char *) -1) {
        perror("shmat");
        exit(1);
    }

    _obj_loc = (obj_loc*)shm;

    string data_dir( getenv( "DEFS_DIR" ));

    if ( data_dir.empty() )
    {
        cout << "DATA_DIR not set. Exiting" << endl;
        exit(1);
    }

    ostringstream stream;
    stream << data_dir << "object_types.t4s";

    string data_file_name = stream.str();
 
    fstream object_type_file(data_file_name.c_str(), ios::in);

    if ( ! object_type_file.is_open() )
    {
        cout << "File " << data_file_name << " not found. Exiting." << endl;
        exit(1);
    }

    char buffer[MAX_OBJECT_TYPES_FILE_LEN];
    char* tok;
    int type_num;
    string type_name;

    while ( object_type_file >> buffer ) 
    {
        tok = strtok( buffer, "," );
        type_num = atoi(tok);
        tok = strtok( NULL, "," );
        type_name = tok;

        _type_map[type_num] = type_name;
    }

    object_type_file.close();

    _status_vec.push_back("UNKNOWN");
    _status_vec.push_back("STOPPED");
    _status_vec.push_back("STARTING");
    _status_vec.push_back("RUNNING");
    _status_vec.push_back("BLOCKED");
    _status_vec.push_back("FAILED");
    _status_vec.push_back("STALE");
    _status_vec.push_back("MANAGED");

    for ( int id = 1 ; id < MAX_OBJECTS ; id++ )
    {


        if ( _obj_loc->shmid[id] != 0 ) {

            row = *(_refTreeModel->append());

            void* tmp;

            if (( tmp = shmat(_obj_loc->shmid[id], NULL, SHM_RDONLY)) == (char *) -1) {
                perror("shmat");
                exit(1);
            }

            _object_headers[id] = ((object_header*)tmp);

            row[_columns._col_last_published] = TimeToString( _object_headers[id]->last_published );
            row[_columns._col_type] = _type_map[_object_headers[id]->type];
            row[_columns._col_name] = _object_headers[id]->name;
            row[_columns._col_sleep_time] = _object_headers[id]->sleep_time;
            row[_columns._col_shmid] = _obj_loc->shmid[id];
            row[_columns._col_status] = _status_vec[_object_headers[id]->status];
            row[_columns._col_pid] = _object_headers[id]->pid;
            row[_columns._col_id] = id;

            my_rows.push_back( row );
        }

    }
    
    _treeView.append_column("ID", _columns._col_id); 
    _treeView.append_column("Type", _columns._col_type);
    _treeView.append_column("Name", _columns._col_name);
    _treeView.append_column("Status", _columns._col_status);
    _treeView.append_column("Sleep time", _columns._col_sleep_time);
    _treeView.append_column("Last published", _columns._col_last_published);
    _treeView.append_column("Shmid", _columns._col_shmid);
    _treeView.append_column("Pid", _columns._col_pid);

    show_all_children();
}

ObjectViewer::~ObjectViewer()
{
}


bool ObjectViewer::Refresh( int timer_number)
{
    Gtk::TreeModel::Row row;

    int id;
    for( int i = 0 ; i < my_rows.size() ; i++ )
    {
        row = my_rows[i];
        id  = row[_columns._col_id];

        row[_columns._col_last_published] = TimeToString( _object_headers[id]->last_published );
        row[_columns._col_type] = _type_map[_object_headers[id]->type];
        row[_columns._col_name] = _object_headers[id]->name;
        row[_columns._col_sleep_time] = _object_headers[id]->sleep_time;
        row[_columns._col_shmid] = _obj_loc->shmid[id];
        row[_columns._col_status] = _status_vec[_object_headers[id]->status];
        row[_columns._col_pid] = _object_headers[id]->pid;

    }
    
    return true;
}

std::string ObjectViewer::TimeToString( time_t time )
{
    string temp_time = ctime(&time);

    return temp_time.substr( 11, 8 );
}

#include <gtkmm/main.h>

int main(int argc, char *argv[])
{
  Gtk::Main kit(argc, argv);

  ObjectViewer window;
  Gtk::Main::run(window); 

  return 0;
}
