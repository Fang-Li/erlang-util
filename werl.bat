cd C:\Users\Administrator\Desktop\lifang\Test\test7
rem ����ebinĿ¼�����ļ�������tab��������
rem ��start��ʽ���������Բ���erlang�����˳���ͬʱ�˳�dos
start werl "-pa" "ebin" -eval "{ok,FileLists} = file:list_dir(ebin),[ begin [File,Suffix] = string:tokens(FileName,\".\") , File2 = erlang:list_to_atom(File), erlang:apply(File2,module_info,[]) end  ||  FileName <- FileLists ], make:all([{compile,export_all},debug_info])."

rem Ҫ�˳�dos����Ȼ���������Ť
exit