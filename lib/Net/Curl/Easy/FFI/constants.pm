package
  Net::Curl::Easy::FFI;
use strict; use warnings;
use constant CURLE_OK                       =>        0;
use constant CURLOPTTYPE_LONG               =>        0;
use constant CURLOPT_VERBOSE                =>       41;
use constant CURLOPT_FOLLOWLOCATION         =>       52;
use constant CURLOPTTYPE_OBJECTPOINT        =>    10000;
use constant CURLOPT_FILE                   =>    10001;
use constant CURLOPT_WRITEDATA              =>    10001;
use constant CURLOPT_URL                    =>    10002;
use constant CURLOPT_USERAGENT              =>    10018;
use constant CURLOPT_HEADERDATA             =>    10029;
use constant CURLOPT_COOKIEFILE             =>    10031;
use constant CURLOPTTYPE_FUNCTIONPOINT      =>    20000;
use constant CURLOPT_WRITEFUNCTION          =>    20011;
use constant CURLOPTTYPE_OFF_T              =>    30000;
1;
