local tests = {}
local tester={}

local run_test_num = 1
local def_test_num = 3

local test_results={}

local print_while_test = false

local orig_print = print
--------------------------------------
-- Main tester setup
---------------------------------------

local function enable_print()
    print = orig_print
end

local function disable_print()
    print = function() end
end

local function btos(value)
   return  (type(value)==type(true) and ( value == true and "true" or "false") or value )
end


function tester.log(type_,state_,message_)
    orig_print("["..type_.."]["..state_.."]  "..btos(message_))
end

local function add_result(result,message)
  table.insert(test_results,{name= tests[run_test_num].name or "N/A",result=result,message=message,id = run_test_num})
end



function tester.run_next()
  if run_test_num > #tests then
    return
  end
  
  
  --for key,val in pairs(tests[run_test_num]) do
  --    print(key,val)
  --end
  
  enable_print()
  if tests[run_test_num].is_test == true then
    print("\n\n-----------------")
    print("START UP NEXT TEST")
    print("  Test id:   "..run_test_num)
    print("  Test name: "..(tests[run_test_num].name or "N/A"))
    print("")
  end
  
  disable_print()
  if tests[run_test_num].setup_function then
    tests[run_test_num].setup_function()
  end
  
  tests[run_test_num].run_function()
    
  if tests[run_test_num].cleanup then
    tests[run_test_num].cleanup()
  end
  
  
  run_test_num= run_test_num +1
end

local function end_testing()
    enable_print()
    print("done testing")
    disable_print()
    os.exit(0)
end

local function start_testing()
    enable_print()
    print("Testing starts now")
    print("We got "..#tests-2 .." tests to run!\n")
    disable_print()
end



function tester.run_tests(queueu_size)
  if run_test_num == 1 then
    table.insert(tests,1,{run_function=start_testing,name="startup",is_test=false,terminates=false})  
    table.insert(tests,{run_function=end_testing,name="end",is_test=false,terminates=false})
  end
    
  disable_print()
  if run_test_num <= #tests then
    for test_count=0,(queueu_size or def_test_num) do
        tester.run_next()
    end
  end
  enable_print()
  
end




--checks if the time equals and the value equals
--also checks dicts...
function tester.equals(a,b)
  enable_print()
  if tester.type_equals(a,b,true) then
    if a == b then 
        print("[VALUECHECKC][SUCCESS] values are the same!  a="..btos(a).."|b="..btos(b))
        disable_print()
        return true 
    else
        print("[VALUECHECKC][FAIL] values are not the same!  a="..btos(a).."|b="..btos(b))
        disable_print()
        return false 
    end
  else
    disable_print()
    return false
  end
  disable_print()
end

function tester.type_equals(a,b,from_up)  
  from_up = from_up or false
  enable_print()
  if type(a) ~= type(b)then
    print("[TYPECHECK][FAIL] types are not the same!")
    if from_up == false then disable_print() end
    return false
  end
  print("[VALUECHECKC][SUCCESS] types are the same!")
  if from_up == false then disable_print() end
  return true
  
end


--infos can have the following params:
-- <string> name : the name of the test (optional)
-- <funct>  run_function :   the function which should be called with the tests  (optional)
-- <funct>  setup_function : the function which should be called before the test ( given via the fist param)
-- <funct>  cleanup        : the function which should be called after the test  (optional)
function tester.add_test(test,infos)
  infos = infos or {}
  if type(infos)~= type({})then
    infos ={}
  end
  
  
  infos["run_function"]=test
  infos["is_test"]=true
  table.insert(tests,infos)
end




----------------------------------------------
-- Own test setup
----------------------------------------------





return tester
