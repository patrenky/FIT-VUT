<?php

function err($errText, $errCode) {
	echo $errText . "\n";
	die($errCode);
}

class Arguments {

	static function shHelp() {
		echo 
"Run php5.6 jsn.php with optional commands:
--input=filename 	(default: stdin)
--output=filename 	(default: stdout)
-h=substChar 		(default: '-')
-n 			(no xml header)
-r=root-element		(default: without root)
--array-name=array-element (default: array)
--item-name=item-element   (default: item)
-s 			(transform string elements)
-i 			(transform number elements)
-l 			(transform literal elements (bool/null))
-c 			(convert &amp; &lt; &gt; etc..)
-a / --array-size 	(add atribute size)
-t / --index-items 	(add atribute index)
--start=n 		(index-items from n number, default: 1)
--types 		(add atribute type of element)
--padding 		(index-items with left padding of 0)
--error-recovery	(trying to fix json syntax problems)\n";
		die(0);
	}

	static 	$inputFile = 'php://stdin',
			$outputFile = 'php://stdout',
			$subst = '-',		$head = true,
			$arrayName = 'array',
			$itemName = 'item',	$root,
			$string, 			$number,
			$literals, 			$convert,
			$arrSize, 			$idxItem,
			$start = 1, 		$types,
			$fixErr, 			$padding;

	static function loadArgs($argv) {
		if ((sizeof($argv) === 1) && ($argv[1] === "--help"))
			self::shHelp();

		foreach ($argv as $argument) {

			if (substr($argument, 0, 8) === '--input=') {
				if (self::$inputFile === null || self::$inputFile === 'php://stdin')
					self::$inputFile = substr($argument, 8);
			}	
			elseif (substr($argument, 0, 9) === '--output=') {
				if (self::$outputFile === null || self::$outputFile === 'php://stdout')
					self::$outputFile = substr($argument, 9);
			}
			elseif (substr($argument, 0, 3) === '-h=') {
				if (self::$subst === null || self::$subst === '-')
					self::$subst = substr($argument, 3);
			}
			elseif ($argument === '-n'){
				self::$head = false;
			}
			elseif (substr($argument, 0, 3) === '-r='){
				if (self::$root === null)
					self::$root = substr($argument, 3);
			}
			elseif (substr($argument, 0, 13) === '--array-name=') {
				if (self::$arrayName === null || self::$arrayName = 'array')
					self::$arrayName = substr($argument, 13);
			}
			elseif (substr($argument, 0, 12) === '--item-name=') {
				if (self::$itemName === null || self::$itemName = 'item')
					self::$itemName = substr($argument, 12);
			}
			elseif ($argument === '-s') {
				self::$string = true;
			}
			elseif ($argument === '-i') {
				self::$number = true;
			}
			elseif ($argument === '-l') {
				self::$literals = true;
			}
			elseif ($argument === '-c') {
				self::$convert = true;
			}
			elseif ($argument === '-a' || $argument === '--array-size') {
				self::$arrSize = true;
			}
			elseif ($argument === '-t' || $argument === '--index-items') {
				self::$idxItem = true;
			}
			elseif (substr($argument, 0, 8) === '--start=') {
				if (self::$start === null || self::$start = 1)
					self::$start = substr($argument, 8);
				if (self::$start < 0)
					err("--start= positive integer", 1);
			}
			elseif ($argument === '--types') {
				self::$types = true;
			}
			elseif ($argument === '--help') {
				err("Try only argument --help", 1);
			}
			elseif ($argument === '--padding') {
				self::$padding = true;
			}
			elseif ($argument === '--error-recovery') {
				self::$fixErr = true;
			}
			else {
				err("Bad argument: " . $argument, 1);
			}
		}

		//check if must be index-item
		if( (self::$start !== 1 && !self::$idxItem) || (self::$padding && !self::$idxItem))
			err("Set -t argument", 1);

		//root, arrayName and itemName validation
		$valid = self::$root . self::$arrayName . self::$itemName;
		if(preg_match('/(<|>|\(|\)|{|}|\[|\]|,|;|\*|%|\$|\?|!|"|&|#|\+|=|~|\`|@|\/)/', $valid, $out))
			err("Invalid xml name", 50);

		//json decode
		Json::readInput(self::$inputFile);
	}
}

class Json {

	static function readInput($file) {
		if ($inputData = @ file_get_contents($file))
			self::fixJson($inputData);
		else
			err("Something wrong with json input file.", 2);
	}

	public static function fixJson($jsn) {
		$res = json_decode($jsn);
				
		if($jsn && !$res) {
			if(Arguments::$fixErr) {
				//missing closing brackets
				$jsn[0] === '[' && substr($jsn, -1) !== ']' && $jsn .= ']';
				$jsn[0] === '{' && substr($jsn, -1) !== '}' && $jsn .= '}';
				//coma errors
				$jsn = preg_replace('/(.*)(,)(\s+)([}\]])/', '$1$3$4', $jsn); // ,}]
				$jsn = preg_replace('/(.*")\s*(".*)/', '$1,$2', $jsn); // ","
				//quotations errors
				$jsn = preg_replace('/(.*):(.*)"((.*)[^"])(,$)/', '$1:$2"$3"$4', $jsn); // "value",
				$jsn = preg_replace('/(\b.*\b)(\s*:.*)/', '"$2"$3', $jsn); // "key":

				return self::fixJson($jsn);
			}
			else {
				err("Set argument --error-recovery", 4);
			}
		}

		//root xml
		$xml = new Xml(Arguments::$root, $res);
		//write output recursive
		$head = Arguments::$head ? "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" : "";
		!@file_put_contents(Arguments::$outputFile, $head.$xml->writeOutput())
			&& err("Something wrong with output.", 3);
	}
}


class Xml {

	private $name, $data, 
			$atribs = array(),
			$type, $array;
	
	function __construct($name, $data) {
		$this->name = $name;
		
		if(is_object($data))
			self::isObject($data);
		elseif(is_array($data))
			self::isArr($data);
		else{ //key - value
			$this->type = gettype($data);
			$this->data = $data;
		}
	}

	//process array
	function isArr($data) {
		$this->array = true;	
		$start = Arguments::$start;

		foreach($data as $key => $value) {
			$this->data[] = new Xml(Arguments::$itemName, $value);
			//index elements and padding enable
			if(Arguments::$idxItem){
				if(Arguments::$padding)
						$start = str_pad($start, strlen($start + count($data) - 1), '0', STR_PAD_LEFT);
				$this->data[count($this->data) - 1]->atribs['index'] = $start;
			}
			$start++;
		}
	}

	//process object
	function isObject($data) {
		$this->data = array();

		foreach($data as $key => $value) {
			$this->data[] = new Xml($key, $value);
		}
	}

	public function writeOutput() {
		$outXml = '';
		$getName = $this->getName();
		$getArrName = $this->getName(Arguments::$arrayName);
		$getAtribs = $this->getAtribs();
		$getValue = $this->getValue();
		$getType = $this->getType();

		if(is_array($this->data)) {
			if(!is_null($this->name)) //start object (item)
				$outXml .= "<". $getName . $getAtribs . ">\n";

			if($this->array) //start array
				$outXml .= "<" . $getArrName
						. (Arguments::$arrSize ? " size=\"" . count($this->data) . "\">\n" : ">\n");

			foreach($this->data as $nested) //recurs
				$outXml .= $nested->writeOutput();

			if($this->array)
				$outXml .= "</" . $getArrName . ">\n";

			if(!is_null($this->name))
				$outXml .= "</" . $getName . ">\n";
		}
		else { //name - value
			$outXml .= "<" . $getName . $getAtribs;
			$outXml .= (Arguments::$types ? " type=\"" . $getType . "\"" : "");

			if ((is_string($this->data) && Arguments::$string) //string -s
				|| ((is_float($this->data) || is_int($this->data)) && Arguments::$number)) //number -i
				 	$outXml .= ">" . $getValue . "</" . $getName . ">\n";

			elseif((is_bool($this->data) || is_null($this->data)) && Arguments::$literals) //literals -l
				 $outXml .= "><" . $getValue . " /></" . $getName . ">\n";

			else //name - value
				 $outXml .= " value=\"" . $getValue . "\" />\n";
		}		
		return $outXml;
	}

	//get name of element, check substitution and validation
	private function getName($name) {
		$name = is_null($name) ? $this->name : $name;
		$name = preg_replace('/(<|>|\(|\)|{|}|\[|\]|,|;|\*|%|\$|\?|!|"|&|#|\+|=|~|\`|@|\/)/', Arguments::$subst, $name);

		if(preg_match('/^(-|[0-9]+)/', $name, $out))
			err("Invalid xml name", 51);

		return $name;
	}

	//get all attributes of element
	public function getAtribs() {
		if(count($this->atribs) == 0)
			return;

		$atrib;
		foreach($this->atribs as $key => $value)
			$atrib .= " " . $key . "=\"" . $value . "\"";		
		return $atrib;
	}

	//get value of element, chceck possible converts
	private function getValue() {
		$value = $this->data;	
		if(is_bool($value))
			return $value ? "true" : "false";
		elseif(is_null($value))
			return "null";
		elseif(is_float($value))
			return floor($value);
		elseif(Arguments::$convert)
			return htmlspecialchars($value);
		else
			return str_replace("\"", "&quot;", $value);
	}

	//get type of element
	private function getType() {
		$type = $this->type;	
		if($type === "double")
			return "real";
		elseif($type === "boolean" || $type === "NULL")
			return "literal";
		else
			return $type;
	}
}

//start here
unset($argv[0]); //filename
Arguments::loadArgs($argv);

?>