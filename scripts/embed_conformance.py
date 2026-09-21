"""Embed official Unicode fixtures without comments; core/tests use no file IO."""
from pathlib import Path
import sys
config = {
 "line": ("LineBreakTest", "linebreak", "line_break_opportunities"),
 "word": ("WordBreakTest", "segment", "word_boundaries"),
 "sentence": ("SentenceBreakTest", "segment", "sentence_boundaries"),
}
for key in sys.argv[1:]:
 name, package, function = config[key]
 lines = [line.split("#")[0].strip() for line in Path("testdata/ucd", name+".txt").read_text(encoding="utf-8").splitlines()]
 lines = [line for line in lines if line]
 content = "// Generated from Unicode 17.0.0 " + name + "; Unicode License v3.\n"
 for start in range(0,len(lines),1000):
  batch=lines[start:start+1000]
  content += '///|\ntest "conformance/'+name+' '+str(start+1)+'-'+str(start+len(batch))+'" {\n  let fixture =\n'
  content += "\n".join("    #|"+line for line in batch)
  content += '\n  let (count, failures) = @conformance.check(fixture, @'+package+'.'+function+')\n'
  content += '  assert_eq(count, '+str(len(batch))+')\n  assert_eq(failures, [])\n}\n\n'
 Path(package, key+"_conformance_test.mbt").write_text(content, encoding="utf-8")
 print(name, len(lines))
