<?php

$v = file_get_contents('php://input');
$f = fopen("out.txt", "w");
fwrite($f,$v);
fclose($f);
