/* Progress Check Syntax by Gabriel Hautclocq */
/* How to use it : C:\Progress\102B\bin\_progres.exe -1 -b -pf C:\Progress\102B\startup.pf -p C:\path\to\syntax.p -param "C:\program_to_check.p" */

DEFINE VARIABLE ch_prog AS CHARACTER NO-UNDO.
DEFINE VARIABLE ch_mess AS CHARACTER NO-UNDO.
DEFINE VARIABLE i       AS INTEGER   NO-UNDO.

def stream mystream.

def temp-table compilerError
  field lineNumber as int
  field errorMessage as char
.

def var vimstring as char no-undo.

/* Extracts the parameters */
assign CH_PROG = entry( 1, session:parameter ).
if num-entries(session:parameter) >= 2 then do :
  assign propath = propath + ":" + entry( 2, session:parameter ).
end.

propath = "".
if not connected("application") then connect value("").

/* Compile without saving */
compile value( CH_PROG ) save=no no-error.

/* If there are compilation messages */
if compiler:num-messages > 0 then do:

  assign CH_MESS = "".

  /* For each messages */
  do I = 1 to compiler:num-messages:

    /* Generate an error line */
    assign CH_MESS =
      substitute( "&1 fILE:'&2' rOW:&3 cOL:&4 eRROR:&5 mESSAGE:&6",
        if compiler:warning = true then "warning" else "error",
        compiler:get-file-name  ( I ),
        compiler:get-row        ( I ),
        compiler:get-column     ( I ),
        compiler:get-number     ( I ),
        compiler:get-message    ( I )
      )
    .
    create compilerError.
    assign
      compilerError.lineNumber = compiler:get-row(i)
      compilerError.errorMessage = compiler:get-message(i)
    .
  end.
  ch_prog = replace(ch_prog, "\", "\\").
  for each compilerError by compilerError.lineNumber:
    vimstring = vimstring + ':exe ":sign place 2 line=' + string(compilerError.lineNumber) + ' name=syntax file=' + ch_prog + '" |'.
    /* vimstring = vimstring + " :exe ':sign place 2 line=" + string(compilerError.lineNumber) + ' name=piet file=" . expand("%:p")'.*/
  end.
  vimstring = vimstring + "~n".
  for each compilerError by compilerError.lineNumber:
    vimstring = vimstring + compilerError.errorMessage + "~n".
  end.
  put unformatted vimstring.
end.
else do :
  vimstring = ":exe 'echo ~"SUCCESS: Syntax is Correct.~"'".
  put unformatted vimstring.
  /* display to the standard output */
  /* PUT UNFORMATTED "SUCCESS: Syntax is Correct." SKIP. */
end.

message vimstring.

disconnect application.
/* End of program */



QUIT.
