for i in `ps -ef | grep steve | grep object | grep -v object_locator | grep " 1 " | awk '{print $2}'`; do kill -1 $i; done

