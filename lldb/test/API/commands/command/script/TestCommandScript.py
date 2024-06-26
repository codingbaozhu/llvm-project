"""
Test lldb Python commands.
"""


import sys
import lldb
from lldbsuite.test.decorators import *
from lldbsuite.test.lldbtest import *


class CmdPythonTestCase(TestBase):
    NO_DEBUG_INFO_TESTCASE = True

    def test(self):
        self.build()
        self.pycmd_tests()

    def pycmd_tests(self):
        self.runCmd("command source py_import")

        # Test that we did indeed add these commands as user commands:
        interp = self.dbg.GetCommandInterpreter()
        self.assertTrue(interp.UserCommandExists("foobar"), "foobar exists")
        self.assertFalse(interp.CommandExists("foobar"), "It is not a builtin.")

        # Test a bunch of different kinds of python callables with
        # both 4 and 5 positional arguments.
        self.expect("foobar", substrs=["All good"])
        self.expect("foobar4", substrs=["All good"])
        self.expect("vfoobar", substrs=["All good"])
        self.expect("v5foobar", substrs=["All good"])
        self.expect("sfoobar", substrs=["All good"])
        self.expect("cfoobar", substrs=["All good"])
        self.expect("ifoobar", substrs=["All good"])
        self.expect("sfoobar4", substrs=["All good"])
        self.expect("cfoobar4", substrs=["All good"])
        self.expect("ifoobar4", substrs=["All good"])
        self.expect("ofoobar", substrs=["All good"])
        self.expect("ofoobar4", substrs=["All good"])

        # Verify command that specifies eCommandRequiresTarget returns failure
        # without a target.
        self.expect("targetname", substrs=["a.out"], matching=False, error=True)

        exe = self.getBuildArtifact("a.out")
        self.expect("file " + exe, patterns=["Current executable set to .*a.out"])

        self.expect("targetname", substrs=["a.out"], matching=True, error=False)

        # This is the function to remove the custom commands in order to have a
        # clean slate for the next test case.
        def cleanup():
            self.runCmd("command script delete welcome", check=False)
            self.runCmd("command script delete targetname", check=False)
            self.runCmd("command script delete longwait", check=False)
            self.runCmd("command script delete mysto", check=False)
            self.runCmd("command script delete tell_sync", check=False)
            self.runCmd("command script delete tell_async", check=False)
            self.runCmd("command script delete tell_curr", check=False)
            self.runCmd("command script delete bug11569", check=False)
            self.runCmd("command script delete takes_exe_ctx", check=False)
            self.runCmd("command script delete decorated", check=False)

        # Execute the cleanup function during test case tear down.
        self.addTearDownHook(cleanup)

        # Interact with debugger in synchronous mode
        self.setAsync(False)

        # We don't want to display the stdout if not in TraceOn() mode.
        if not self.TraceOn():
            self.HideStdout()

        self.expect("welcome Enrico", substrs=["Hello Enrico, welcome to LLDB"])

        self.expect(
            "help welcome",
            substrs=[
                "Just a docstring for welcome_impl",
                "A command that says hello to LLDB users",
            ],
        )

        decorated_commands = ["decorated" + str(n) for n in range(1, 5)]
        for name in decorated_commands:
            self.expect(name, substrs=["hello from " + name])
            self.expect(
                "help " + name, substrs=["Python command defined by @lldb.command"]
            )

        self.expect(
            "help",
            substrs=["For more information run"] + decorated_commands + ["welcome"],
        )

        self.expect(
            "help -a",
            substrs=["For more information run"] + decorated_commands + ["welcome"],
        )

        self.expect("help -u", matching=False, substrs=["For more information run"])

        self.runCmd("command script delete welcome")

        self.expect(
            "welcome Enrico",
            matching=False,
            error=True,
            substrs=["Hello Enrico, welcome to LLDB"],
        )

        self.expect(
            "targetname fail", error=True, substrs=["a test for error in command"]
        )

        self.expect(
            "command script list", substrs=["targetname", "For more information run"]
        )

        self.expect(
            "help targetname",
            substrs=["Expects", "'raw'", "input", "help", "raw-input"],
        )

        self.expect("longwait", substrs=["Done; if you saw the delays I am doing OK"])

        self.runCmd("break set -f main.cpp -l 48")
        self.runCmd("run")
        self.runCmd("mysto 3")
        self.expect(
            "frame variable array",
            substrs=["[0] = 79630", "[1] = 388785018", "[2] = 0"],
        )
        self.runCmd("mysto 3")
        self.expect(
            "frame variable array",
            substrs=["[0] = 79630", "[4] = 388785018", "[5] = 0"],
        )

        # we cannot use the stepover command to check for async execution mode since LLDB
        # seems to get confused when events start to queue up
        self.expect("tell_sync", substrs=["running sync"])
        self.expect("tell_async", substrs=["running async"])
        self.expect("tell_curr", substrs=["I am running sync"])

        # check that the execution context is passed in to commands that ask for it
        self.expect("takes_exe_ctx", substrs=["a.out"])

        # Test that a python command can redefine itself
        self.expect('command script add -f foobar welcome -h "just some help"')

        self.runCmd("command script clear")

        # Test that re-defining an existing command works
        self.runCmd("command script add my_command --class welcome.WelcomeCommand")
        self.expect("my_command Blah", substrs=["Hello Blah, welcome to LLDB"])

        self.runCmd(
            "command script add my_command -o --class welcome.TargetnameCommand"
        )
        self.expect("my_command", substrs=["a.out"])

        # Test that without --overwrite we are not allowed to redefine the command.
        self.expect(
            "command script add my_command --class welcome.TargetnameCommand",
            substrs=[
                (
                    'user command "my_command" already exists and force replace was'
                    " not set by --overwrite or 'settings set"
                    " interpreter.require-overwrite false'"
                ),
            ],
            error=True,
        )

        self.runCmd("command script clear")

        self.expect(
            "command script list", matching=False, substrs=["targetname", "longwait"]
        )

        self.expect(
            "command script add -f foobar frame",
            error=True,
            substrs=["cannot add command"],
        )

        # http://llvm.org/bugs/show_bug.cgi?id=11569
        # LLDBSwigPythonCallCommand crashes when a command script returns an
        # object
        self.runCmd("command script add -f bug11569 bug11569")
        # This should not crash.
        self.runCmd("bug11569", check=False)

        # Make sure that a reference to a non-existent class raises an error:
        bad_class_name = "LLDBNoSuchModule.LLDBNoSuchClass"
        self.expect(
            "command script add wont-work --class {0}".format(bad_class_name),
            error=True,
            substrs=[bad_class_name],
        )

    def test_persistence(self):
        """
        Ensure that function arguments meaningfully persist (and do not crash!)
        even after the function terminates.
        """
        self.runCmd("command script import persistence.py")
        self.runCmd("command script add -f persistence.save_debugger save_debugger")
        self.expect("save_debugger", substrs=[str(self.dbg)])

        # After the command completes, the debugger object should still be
        # valid.
        self.expect("script str(persistence.debugger_copy)", substrs=[str(self.dbg)])
        # The result object will be replaced by an empty result object (in the
        # "Started" state).
        self.expect("script str(persistence.result_copy)", substrs=["Started"])

    def test_interactive(self):
        """
        Test that we can add multiple lines interactively.
        """
        interp = self.dbg.GetCommandInterpreter()
        cmd_file = self.getSourcePath("cmd_file.lldb")
        result = lldb.SBCommandReturnObject()
        interp.HandleCommand(f"command source {cmd_file}", result)
        self.assertCommandReturn(result, "Sourcing the command should cause no errors.")
        self.assertTrue(interp.UserCommandExists("my_cmd"), "Command defined.")
        interp.HandleCommand("my_cmd", result)
        self.assertCommandReturn(result, "Running the command succeeds")
        self.assertIn("My Command Result", result.GetOutput(), "Command was correct")
