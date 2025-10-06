import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;


// The Student record to load records from `albums` table.
type Student record {|
    @sql:Column {name: "id"}
    int id;

    @sql:Column {name: "name"}
    string name;

    @sql:Column {name: "school"}
    string school;
    
    @sql:Column {name: "grade"}
    string grade;
|};

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /student on httpDefaultListener {

    private final mysql:Client db;

    function init() returns error? {
        // Initiate the mysql client at the start of the service. This will be used
        // throughout the lifetime of the service.
        
        //Cloud config
        //string dbIP="bijira-mysql-4081075185.dp-development-pablosa-7278-2606825535.svc.cluster.local"
        //int dbPort = 8080;
        
        //Onpremise config
        string dbIP="100.110.11.106"; 
        int dbPort = 3306;


        self.db = check new (dbIP, "root", "pass", "school_db", dbPort);
    }

    resource function get students() returns Student[]|error {
        // Execute simple query to retrieve all records from the `albums` table.
        stream<Student, sql:Error?> studentStream = self.db->query(`SELECT * FROM students`);

        // Process the stream and convert results to Album[] or return error.
        return from Student student in studentStream
            select student;
    }

    resource function get greeting() returns error|json|http:InternalServerError {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
