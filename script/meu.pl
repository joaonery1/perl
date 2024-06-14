#!/usr/bin/perl -w
#package perlModules::common;

#use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw( LineStartMultiLineComment
                     LineStartSingleLineComment
                     LineStartCleanComments
                     LineStartParenthesis
                     LineStartTypeStar
                     LineStartVariable
                     LineStartDefault
                     LineStartSeparator
                   );


#############################################################################
# LineStartMultilineComment
#
# Returns the string from the "/*" if found in start of $line, blank string 
# if not found. Matches the smallest string between /* and */
# 
sub LineStartMultiLineComment { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*(/\*[\w\W]*?\*/)##;
  return ($1, $line);
}

#############################################################################
# LineStartSingleLineComment
#
# Returns the string after the "//" to the first "\n" if found 
# in start of $line, blank string if not found.
# 
sub LineStartSingleLineComment { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*//\s*(.*)\s*\n##;
  #$line =~ s#^\s*//(.*)##;
  return ($1, $line);
}

#############################################################################
# LineStartCleanComments
#
# Throws away comments in begginning of $line
# 
sub LineStartCleanComments { # ($line) {
  my $line = $_[0];

  my $multi  = "foo";
  my $single = "foo";

  #print "LineStartCleanComments:\n";

  while ($multi or $single){
    ($multi, $line) = LineStartMultiLineComment($line);
    ($single, $line) = LineStartMultiLineComment($line);

    if ($single){
      #print "Single = $single\n";
    }
    if ($multi){
      #print "Multi = $multi\n";
    }
  }
  return $line;
}

#############################################################################
# LineStartParenthesis
#
# Returns the string after the "(" 
# in start of $line, blank string if not found.
# 
sub LineStartParenthesis { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*\((.*)##;
  return $1;
}

#############################################################################
# LineStartType
#
# Returns the datatype in start of $line, blank string if not found.
# 
sub LineStartType { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*([a-zA-Z_]\w*)##;
  return ($1, $line);
}

#############################################################################
# LineStartTypeStar
#
# Returns the string after the datatype and, * if present,
# in start of $line, blank string if not found.
# 
sub LineStartTypeStar { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*(unsigned)?(\s*[a-zA-Z_]\w*[\s*\*]*)##;
  my $result1 = $1;
  my $result2 = $2;
  $result2 =~ s#\s##g;
  my $result;
  if ($result1 eq ""){
    $result = $result2;
  }
  else
  {
    $result = "$result1 $result2";
  }

  return ($result, $line);
}

#############################################################################
# LineStartVariable
#
# Returns the variable name 
# in start of $line, blank string if not found.
# 
sub LineStartVariable { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*([a-zA-Z_]\w*)##;
  return ($1, $line);
}

#############################################################################
# LineStartDefault
#
# Returns the string, after the variable
# in start of $line, that defines its default value, blank string if not found.
# 
sub LineStartDefault { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*(=\s*-?\s*[\.\w]*)##;
  return ($1, $line);
}

#############################################################################
# LineStartSeparator
#
# Returns the string after the first "," or ")" found
# in start of $line, blank string if not found.
# 
sub LineStartSeparator { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*(,|\))##;
  return ($1, $line);
}






1;
#---------------------------------------------------------------------------------------------#
#                                        INICIO DO CL2PY                                      #
#---------------------------------------------------------------------------------------------#

use File::Basename;
#use perlModules::common qw( LineStartMultiLineComment
#               LineStartSingleLineComment
#               LineStartCleanComments
#               LineStartParenthesis
#               LineStartTypeStar
#               LineStartVariable
#               LineStartDefault
#               LineStartSeparator
#             );

#############################################################################
# LineStartCommentedDefault
#
# Returns the string, between /* and */, after the variable
# in start of $line, that defines its default value, blank string if not found.
#
sub LineStartCommentedDefault { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*/\*\s*(=\s*[\.\w]*)\s*\*/##;
  return ($1, $line);
}

#############################################################################
# LineStartPreamble
#
# Eliminates preamble, i.e., typedefs and includes, before __kernel header.
#
sub LineStartPreamble { # ($line) {
  my $line = $_[0];

  # *? is ungreedy match;
  # s modifier makes . match new line
  $line =~ s#^\s*(typedef\s*struct\s*\w*\s*\{.*?\}\s*\w*\s*;)##s;
  $result = $1;
  if ($result)
  {
    return ($result, $line);
  }

  $line =~ s#^\s*(\#\s*include\s*[\"<].*?[\">])##s;
  $result = $1;
  return ($result, $line);

}

#############################################################################
# LineStartHeader
#
# Returns the header of the program, that is, the
# text starting with __kernel until the character before {
#
sub LineStartHeader { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*((__kernel)\s*(void)[\s\S]*?)\{##; # *? is ungreedy match
  $result = $1;
  $result =~ s#\s+# #g;

  return ($result, $line);
}

#############################################################################
# LineStartSemantics
#
# Returns the string after the semantic binding and the ":"
# in start of $line, blank string if not found.
# Valid semantic bindings are __read_only, __write_only, __read_write,
# __constant and __global.
#
sub LineStartSemantics { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*(__read_only|__write_only|__read_write|__constant|__global)\s*##;
  $semantics = $1;
  if ($semantics){
    if (!($semantics =~ m#^(__read_only|__write_only|__read_write|__constant|__global)$#))
    {
      print "Semantic $semantics invalid. Valid semantics are (__read_only|__write_only|__read_write|__constant|__global)\n";
    }
  }
  else{
    $semantics = "";
  }
  return ($semantics, $line);
}

#############################################################################
# LineStartDirective
#
# Returns the string after the directive
# in start of $line, blank string if not found.
# Valid directives are SCALAR, ARRAY and SHAPE
#
sub LineStartDirective { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*([a-zA-Z_]\w*)\s*##;
  my $result = $1;
  print "Directive type >>>$result<<<\n";
  if ($result){
    if (!($result =~ m#^(SCALAR|ARRAY|SHAPE)$#))
    {
      die "Directive $result invalid. Valid directives are (SCALAR|ARRAY|SHAPE)\n";
    }
  }
  else{
    $result = "";
  }
  return ($result, $line);
}

#############################################################################
# LineStartSize
#
# Returns the string between [] in
# start of $line, blank string if not found.
#
sub LineStartSize { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*\[\s*(.*)\s*\]##;
  my $result = $1;
  print "Found size >>>$result<<<\n";
  return ($result, $line);
}

#############################################################################
# LineStartValue
#
# Returns the expression between () in
# start of $line, blank string if not found.
#
sub LineStartValue { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*\(\s*(.*)\s*\)##;
  my $result = $1;
  print "Found value >>>$result<<<\n";
  return ($result, $line);
}

#############################################################################
# LineStartMain
#
# Returns the string that contains the expression __kernel void.
#
sub LineStartMain { # ($line) {
  my $line = $_[0];

  $line =~ s#^\s*((__kernel)\s*(void)\s*)##;
  return ($1, $line);
}

#############################################################################
# ProcessClDirectives
#
# Receives as input an array of CL directives and links them to the respective variables
#
# A CL Directive purpose is to specify the size of arrays passed as parameters to
# a kernel. The size is needed by the wrapper to calculate the buffer size. The buffer
# size is passed as parameter to clCreateBuffer and clEnqueueWriteBuffer.
#
sub foo{
$bar = '
sub ProcessClDirectives { # ($directives, $variable) {
  my $directives   = $_[0];
  my $variable     = $_[1];

  my $i = 0;
  my $j = 0;

  my $result_directive;
  my $result_variable;
  my $result_size;


  print "ProcessClDirectives directives size = $#directives\n";
  print "ProcessClDirectives variable size   = $#variable\n";

  for ($i = 0; $i <= $#variable; $i++){
    $is_array[$i] = 0;
    $size[$i]     = "1";
    print "-----------Is array [$i]: $is_array[$i]\n";
    print "-----------Size     [$i]: $size[$i]\n";

  }


  print "ProcessClDirectives directives size = $#directives\n";
  die;

  for ($i = 0; $i <= $#directives; $i++){
    print "###########################################################\n";
    print "Processing directive comment[$i]: >>>>$directives[$i]<<<<\n";

    ($result_directive, $directives[$i]) = LineStartDirective($directives[$i]);
    print "1 Directive type = >>>$result_directive<<<\n";
    if (!$result_directive){
      die "Error: Start-of-line directive (SCALAR|ARRAY|SHAPE) not found\n";
    }
    else{
      print "After eliminating directive (SCALAR|ARRAY|SHAPE):\n$directives[$i]\n";
    }

    ($result_variable, $directives[$i]) = LineStartVariable($directives[$i]);
    print "2 Variable name = >>>$result_variable<<<\n";
    if (!$result_variable){
      die "Error: Start-of-line variable name not found\n";
    }
    else{
      print "After eliminating variable name:\n$directives[$i]\n";
    }

    print "3 CHECK Directive value = >>>$result_directive<<<\n";

    print "3 Directive value = >>>$result_directive<<<\n";
    if ($result_directive eq "ARRAY"){
      print "Searching size of ARRAY type directive\n";
      ($result_size, $directives[$i]) = LineStartSize($directives[$i]);
      if (!$result_size){
        die "Error: Start-of-line size value not found\n";
      }
      else{
        print "After eliminating size value:\n$directives[$i]\n";
      }
    }
    elsif ($result_directive eq "SHAPE"){
      print "Searching value of SHAPE type directive\n";
      ($result_val, $directives[$i]) = LineStartValue($directives[$i]);
      print "SHAPE result value: $result_val\n\n";
      if (!$result_val){
        die "Error: Start-of-line value not found\n";
      }
      else{
        print "After eliminating value:\n$directives[$i]\n";
      }
    }

    print "FOR STARTING $#variable\n";
    for ($j = 0; $j <= $#variable; $j++){
      print ">>>$result_variable<<< == >>>$variable[$j]<<<\n";
      if ($result_variable eq $variable[$j]){
        if ($result_directive eq "ARRAY"){
          $is_array[$j] = 1;
          $size[$j] = $result_size;
          print "Is array [$j]: $is_array[$j]\n";
          print "Size     [$j]: $size[$j]\n";
        }
      }
    }
  }

    for ($j = 0; $j <= $#variable; $j++){
          print "Is array [$j]: $is_array[$j]\n";
          print "Size     [$j]: $size[$j]\n";
    }

  return ($is_array, $size);

}
';
}

#############################################################################
# ProcessClDirective
#
# Receives as input a CL directive and returns directive type, variable name and size.
#
# A CL Directive purpose is to specify the size of arrays passed as parameters to
# a kernel. The size is needed by the wrapper to calculate the buffer size. The buffer
# size is passed as parameter to clCreateBuffer and clEnqueueWriteBuffer.
#
sub ProcessClDirective { # ($directive) {
  my $directive   = $_[0];

  my $i = 0;
  my $j = 0;

  my $result_directive;
  my $result_variable;
  my $result_size;
  my $result_isarray;
  my $result_isshape;


    print "ProcessingClDirective started###########################################################\n";
    print "ProcessClDirective directives size = $#directive\n";
    print "Processing directive comment[$i]: >>>>$directive<<<<\n";

    ($result_directive, $directive) = LineStartDirective($directive);
    print "1 Directive type = >>>$result_directive<<<\n";
    if (!$result_directive){
      die "Error: Start-of-line directive (SCALAR|ARRAY|SHAPE) not found\n";
    }
    else{
      print "After eliminating directive (SCALAR|ARRAY|SHAPE):\n$directive\n";
    }

    ($result_variable, $directive) = LineStartVariable($directive);
    print "2 Variable name = >>>$result_variable<<<\n";
    if (!$result_variable){
      die "Error: Start-of-line variable name not found\n";
    }
    else{
      print "After eliminating variable name:\n>>>$directive<<<\n";
    }

    print "3 Directive type = >>>$result_directive<<<\n";
    #print "3 CHECK Directive type = >>>$result_directive<<<\n";
    if ($result_directive eq "ARRAY"){
      print "Searching size of ARRAY type directive\n";
      ($result_size, $directive) = LineStartSize($directive);
      if (!$result_size){
        die "Error: Start-of-line size value not found\n";
      }
      else{
        print "After eliminating size value:\n$directive\n";
      }
    }
    elsif ($result_directive eq "SHAPE"){
      print "Searching value of SHAPE type directive\n";
      ($result_size, $directive) = LineStartValue($directive);
      print "SHAPE result value: $result_val\n\n";
      if (!$result_size){
        die "Error: Start-of-line value not found\n";
      }
      else{
        print "After eliminating value:\n$directives[$i]\n";
      }
    }


    $result_isarray = 0;
    if ($result_directive eq "ARRAY"){
      $result_isarray = 1;
    }

    $result_isshape = 0;
    if ($result_directive eq "SHAPE"){
      $result_isshape = 1;
    }

  return ($result_variable, $result_size, $result_isarray, $result_isshape);

}

#############################################################################
# ProcessClHeader
#
# Receives as input a CL header line and breaks it
#
#
sub ProcessClHeader { # ($line) {
  my $line          = $_[0];

  my $result;
  my $kernelname;
  my $separator;
  my $semantics;
  my $type;
  my $output;
  my $variable;

  ($result, $line) = LineStartMain($line);
  if (!$result){
    die "Error: Start-of-line \"__kernel void\" not found\n";
  }
  else{
    #print "After eliminating \"__kernel void\":\n$line\n";
  }

  ($kernelname, $line) = LineStartVariable($line);
  if (!$kernelname){
    die "Error: Start-of-line kernel name identifier not found\n";
  }
  else{
    #print "After eliminating kernel name \"$kernelname\":\n$line\n";
  }


  $line = LineStartParenthesis($line);
  if (!$line){
    die "Error: Start-of-line parenthesis not found\n";
  }
  else{
    #print "After eliminating parenthesis:\n$line\n";
  }

  ($separator, $line) = LineStartSeparator($line);

  if ($separator and $separator eq ")"){
    print "No parameters found\n";
    return;
  }

  my $i = 0;

  $separator = ",";
  while ($separator and $separator eq ","){

    ($semantics[$i], $line) = LineStartSemantics($line);
    if (!$semantics[$i]){
      print "Start-of-line semantics not found\n";
    }
    else{
      print "After eliminating semantics:\n$line\n";
    }

    ($type[$i], $line) = LineStartTypeStar($line);
    if (!$type[$i]){
      print "Start-of-line type not found\n";
    }
    else{
      #print "After eliminating type:\n$line\n";
    }

    ($variable[$i], $line) = LineStartVariable($line);
    if (!$variable[$i]){
      print "Start-of-line variable not found\n";
    }
    else{
      #print "After eliminating variable:\n$line\n";
    }

    ($default[$i], $line) = LineStartCommentedDefault($line);
    if (!$default[$i]){
      #print "Start-of-line default not found\n";
    }
    else{
      #print "After eliminating variable:\n$line\n";
    }

    ($separator, $line) = LineStartSeparator($line);

    if ($separator and $separator eq ","){
      #print "Variable list continues\n";
    }

    print "Semantics[$i]: " . ($semantics[$i] or "") . "\n";
    print "Type     [$i]: $type[$i]\n";
    print "Variable [$i]: $variable[$i]\n";
    print "Default  [$i]: " . ($default[$i] or "") . "\n";

    $i++;
  }
  print "variable size ====== $#variable\n";

  return ($semantics, $type, $variable, $default, $kernelname);

}

#############################################################################
# ProcessClFile
#
# Receives as input a CL filename and generates CPP wrapper function
#
#
sub ProcessClFile { # ($filename, $output, $cpp_read_path) {
  my $filename      = $_[0];
  my $output        = $_[1];
  my $cpp_read_path = $_[2];

  my $comment;
  my $semantics;
  my $type;
  my $variable;
  my $default;
  my $uniform;
  my $dircomment;
  my $is_array;
  my $size;

  print "directive size = $#dircomment\n";

  undef $comment;
  undef $semantics;
  undef $type;
  undef $variable;
  undef $default;
  undef $uniform;
  undef $dircomment;
  undef $is_array;
  undef $size;

  print "directive size = $#dircomment\n";
  #print "directive 0 = $dircomment[0]\n";
  #print "directive 1 = $dircomment[1]\n";
  print "commment size = $#comment\n";
  print "semantics size = $#semantics\n";
  print "type size = $#type\n";
  print "variable size = $#variable\n";

  open CL, $filename;
  @list = <CL>;
  $line = join("", @list);
  close CL;

  ($comment, $line) = LineStartMultiLineComment($line);
  if (!$comment){
    print "Start-of-file comment not found\n";
  }
  else{
    print "Found this comment:\n$comment\n";
  }

  print "directive size = $#directive\n";

  my $i = 0;
  my $catdirectives = "";
  do {
    ($dircomment[$i], $line) = LineStartSingleLineComment($line);
    print "directive[$i] = >>$dircomment[$i]<< size = >>$#dircomment<<\n";
    if ($dircomment[$i]){
      print ("Found directive: $dircomment[$i]\n");
      ($dirvar[$i], $dirsize[$i], $dirisarray[$i], $dirisshape[$i]) = ProcessClDirective($dircomment[$i]);
      print ("ProcessClFile result = <$dirvar[$i]> <$dirsize[$i]> <$dirisarray[$i]> <$dirisshape[$i]>\n");
    }
    else{
      #print ("Directive not found\n");
    }
    $i++;
  }
  while ($dircomment[$i-1]);
  delete $dircomment[$i-1];
  print "DIRECTIVE SIZE AFTER LineStartSingleLineComment: $#dircomment\n";

  print "Starting loop to print directives found\n";
  for($i = 0; $i <= $#dirvar; $i++){
      print ("ProcessClFile result = <$dirvar[$i]> <$dirsize[$i]> <$dirisarray[$i]> <$dirisshape[$i]>\n");
  }

  print "Eliminating preamble (typedef|include)\n\n\n\n";
  do
  {
    ($preamble, $line) = LineStartPreamble($line);

  }
  while ($preamble);

  ($perl_header, $line) = LineStartHeader($line);
  if (!$perl_header){
    print "Error: start-of-file header not found\n";
    return;
  }
  else{
    print "Found this header:\n$perl_header\n";
  }

  ($semantics, $type, $variable, $default, $kernelname) = ProcessClHeader($perl_header);
  print "variable size = $#variable\n";
  print "ProcessClFile dircomment size = $#dircomment\n";


  for($i = 0; $i <= $#variable; $i++){
    $is_array[$i] = 0;
    $is_shape[$i] = 0;
    $size[$i]     = 1;
  }
  print "Linking variables to directives:\n";
  for($i = 0; $i <= $#variable; $i++){
    for ($j = 0; $j <= $#dirvar; $j++){
       print ">>>$variable[$i]<<< == >>>$dirvar[$j]<<<\n";
       if ($variable[$i] eq $dirvar[$j] && $dirisarray[$j]){
         $is_array[$i] = $dirisarray[$j];
         $size[$i]     = $dirsize[$j];
         print "Is array [$i]: $is_array[$i]\n";
         print "Size     [$i]: $size[$i]\n";
       }
       if ($variable[$i] eq $dirvar[$j] && $dirisshape[$j]){
         $is_shape[$i] = $dirisshape[$j];
         $size[$i]     = $dirsize[$j];
         print "Is shape [$i]: $is_shape[$i]\n";
         print "Value    [$i]: $size[$i]\n";
       }
     }
   }

  my $j = 0;

  if ($kernelname ne $basename){
    die "Error: File basename \"$basename\" != kernel name \"$kernelname\". Please rename your kernel to \"$basename\"\n";
  }
  #$line = LineStartCleanComments($line);

  print "\n";
  for($i = 0; $i <= $#variable; $i++){
    print "Semantics[$i]: " . ($semantics[$i] or "") . "\n";
    print "Type     [$i]: $type[$i]\n";
    print "Variable [$i]: $variable[$i]\n";
    print "Default  [$i]: " . ($default[$i] or "") . "\n";
    print "Array?   [$i]: $is_array[$i]\n";
    print "Shape?   [$i]: $is_shape[$i]\n";
    print "Size     [$i]: $size[$i]\n";
  }

  return  ($comment, $semantics, $type, $variable, $is_array, $is_shape, $size);
}

#############################################################################
# PrintPythonFile
#
# Receives as input a CL filename and generates Python wrapper function
#
#
sub PrintPythonFile {
  my $basename      = $_[0];
  my $comment       = $_[1];
  my $semantics     = $_[2];
  my $type          = $_[3];
  my $variable      = $_[4];
  my $default       = $_[5];
  my $is_array      = $_[6];
  my $is_shape      = $_[7];
  my $size          = $_[8];
  my $output        = $_[9];
  my $cpp_read_path = $_[10];

  my $i;
  my $first_framebuffer = "";
  my $vetor_ou_image = "";

  print "Will write to $output.py\n";

  open PYTHON, ">>", "$output.py";

  print PYTHON "\"\"\"\n    $comment    \n\"\"\"\n";
  print PYTHON "elif vGlyph.func == '$basename':\n";

  # Gerar a linha para obter as imagens de entrada e saída
  for ($i = 0; $i <= $#type; $i++){
    if ($type[$i] eq "VglImage*"){
      if ($semantics[$i] eq "__read_only") {
        print PYTHON "    ${basename}_img_input = getImageInputByIdName(vGlyph.glyph_id, '$variable[$i]');\n";
      } elsif ($semantics[$i] eq "__write_only") {
        print PYTHON "    ${basename}_img_output = getImageInputByIdName(vGlyph.glyph_id, '$variable[$i]');\n";
      }
    }
  }

  # Verificar o contexto da imagem de saída
  for ($i = 0; $i <= $#type; $i++){
    if ($semantics[$i] eq "__write_only"){
      print PYTHON "    vl.vglCheckContext(${basename}_img_output, vl.VGL_CL_CONTEXT())\n";
    }
  }

  # Gerar a chamada da função com os parâmetros corretos
  if ($basename eq "vglClThreshold") {
    print PYTHON "    $basename(${basename}_img_input, ${basename}_img_output, np.float32(vGlyph.lst_par[0].getValue()))\n";
  } else {
    my $function_call = "    $basename(";
    my @params;
    for ($i = 0; $i <= $#variable; $i++) {
      if ($semantics[$i] eq "__read_only") {
        push @params, "${basename}_img_input";
      } elsif ($semantics[$i] eq "__write_only") {
        push @params, "${basename}_img_output";
      } else {
        if ($i == 2) {
          push @params, "tratnum(vGlyph.lst_par[0].getValue())";
        } elsif ($i == 3) {
          push @params, "np.uint32(vGlyph.lst_par[1].getValue())";
        } elsif ($i == 4) {
          push @params, "np.uint32(vGlyph.lst_par[2].getValue())";
        }
      }
    }
    $function_call .= join(", ", @params) . ")";
    print PYTHON "$function_call\n";
  }

  # Adicionar a linha GlyphExecutedUpdate usando a variável correta
  print PYTHON "    GlyphExecutedUpdate(vGlyph.glyph_id, ${basename}_img_output)\n";

  close PYTHON;
}





#############################################################################
# PrintHtmlFile
#
# Receives as input a CL filename and generates html tags
#
#
sub PrintHtmlFile { # ($basename, $comment, $semantics, $type, $variable, $default, $uniform, $output, $cpp_read_path) {
  my $basename      = $_[0];
  my $comment       = $_[1];
  my $semantics     = $_[2];
  my $type          = $_[3];
  my $variable      = $_[4];
  my $default       = $_[5];
  my $is_array      = $_[6];
  my $size          = $_[7];
  my $output        = $_[8];
  my $cpp_read_path = $_[9];

  my $i;
  my $first_framebuffer = "";

  print "Will write to $output.html\n";

  open HTML, ">>", "$output.html";

  print HTML "<div class=\"lblock ui-corner-all noselect\">";
  print HTML "<div class=\"ui-widget-header ui-corner-top\">$basename</div>";
  print HTML "<div class=\"ui-widget-content ui-corner-bottom\">";

  for ($i = 0; $i <= $#type; $i++){
    if ($semantics[$i] eq "__read_only"){
      print HTML "<p class=\"pleft\"><span class=\"vertex in ";
    }else{
      if ($semantics[$i] eq "__write_only"){
        print HTML "<p class=\"pright\"><span class=\"vertex out ";
      }else{
        print HTML "<p class=\"pleft\"><span class=\"vertex in ";
      }
    }

    if ($type[$i] eq "VglImage*"){
      print HTML "image";
    }else{
      print HTML "$type[$i]";
    }
    print HTML "\"></span>$variable[$i]</p>";

  }

  print HTML "</div>";
  print HTML "</div>";

  close HTML;
}

#############################################################################
# Main program
#
#

$USAGE="
Usage:

cl2cpp  [-o OutputFile] [-p ShadersPath] InputFileList

OutputFile      Source file to which the output will be written. Two files
                are written with this prefix, a \".cpp\" and a \".h\".
                It is optional and the default is \"cl2cpp_shaders\".

ShadersPath     Path to shader files, added to cpp source code before the
                shader file name. Default is blank.

InputFileList   List of input files. Wildcard characters are allowed.
                Must be placed after the other parameters.

";

print $USAGE;

##################
# PYTHON WRAPPER #
##################

my $archiveName = "cl2py_shaders";
$nargs = $#ARGV;
$nargs++;
print "Number of args = $nargs\n";


for ($i=0; $i<$nargs; $i=$i+2) {
  if    ($ARGV[$i] eq "-o") {
    $output = $ARGV[$i+1] ;
    print ("Output Files: $output.py\n") ;
  }
  elsif ($ARGV[$i] eq "-p") {
    $cpp_read_path = $ARGV[$i+1] ;
    print ("Shader files search path: $cpp_read_path\n") ;
  }
  else {
    last;
  }
}

if (!$output){
  $output = $archiveName;
}


if (!$cpp_read_path){
  $cpp_read_path = "";
}
elsif ($cpp_read_path =~ m#[^/]$#){
  $cpp_read_path = "$cpp_read_path/";
}


$firstInputFile = $i;

my @files = ();
for ($i=$firstInputFile; $i<$nargs; $i=$i+1) {
  push @files, glob $ARGV[$i];
}
print "Size of files = $#files\n";
for ($i=0; $i<=$#files; $i=$i+1) {
    print $files[$i], "\n";
}

unlink("$output.py");

$topMsg = "
\"\"\"
    ************************************************************************
    ***                                                                  ***
    ***                Source code generated by cl2py.pl                 ***
    ***                                                                  ***
    ***                        Please do not edit                        ***
    ***                                                                  ***
    ************************************************************************
\"\"\"\n";

my $className = substr($cpp_read_path, 0, length($cpp_read_path)-1); # removes last character, that is '/'

open PYTHON, ">>", "$output.py";
print PYTHON $topMsg;
print PYTHON "#!/usr/bin/python3 python3

# OPENCL LIBRARY
import pyopencl as cl

# VGL LIBRARYS
import vgl_lib as vl

#TO WORK WITH MAIN
import numpy as np\n\n";
close PYTHON;

$i = 0;

for ($i=0; $i<=$#files; $i++) {
    $fullname = $files[$i];

    print "====================\n";
    print "$files[$i]\n";
    print "i = $i\n";
    print "nargs = $nargs\n";
    ($a, $b, $c) = fileparse($fullname, ".cl");
    $a or $a = "";
    $b or $b = "";
    $c or $c = "";
    print "Path: $b\n";
    print "Basename: $a\n";
    print "Extenssion: $c\n";
    $basename = $a;

    undef $comment;
    undef @semantics;
    undef @type;
    undef @variable;
    undef @uniform;


    ($comment, $semantics, $type, $variable, $default, $uniform) = ProcessClFile($fullname);

    PrintPythonFile($basename, $comment, $semantics, $type, $variable, $default, $is_array, $is_shape, $size, $output, $cpp_read_path);

}
