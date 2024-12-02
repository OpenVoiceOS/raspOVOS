#!/bin/bash

echo -e "\e[1;31m
                                     ++.  .::::.  .++.
                                    :****%@@@@@@%*+**:
                         :++        -#@@@@@@@@@@@@@@#=        ++:
                         -**.      .%@@@@@@@@@@@@@@@@%.       **=
                         =**:     .%@@@@@@@@@@@@@@@@@@%.     .**+
                         +**-    .%@@@@@@@@@@@@@@@@@@@@%:    -***
                         ***=   .%@@@@@@@@@@@@@@@@@@@@@@%    =***
                 :-.     ***+   *@@@@@@@@@@@@@@@@@@@@@@@@#   +***.     -:
                .**+    .****  =@@@@@@@@@@@@@@@@@@@@@@@@@@+  ****:    =**:
                :***    :****.:%@@@@@@@@@@@@@@@@@@@@@@@@@@@:.****:    +**-
                -***.   -****:#@@@@@@@@@@@@@@@@@@@@@@@@@@@@#:****-   .***=
        -*+.    =***:   =****#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*****=   :***+    .+*=
       .***-    +***=   =****@@@@@@@@@@@%%#%@@@@@@@@@@@@@@@@@****+   -****    -***:
       =***+    ****+   +***%@@@@@@@@*-. .. .-*@@@@@@@@@@@@@@%***+   +****.   =***=
       *****   .*****   ****@@@@@@@#. -+ ...+. -#+--:-=+#@@@@@#***   *****:   *****.
      -*****:  :*****. .***%@@@@@@@:  .%=..**    ..:-:...-%@@@%***. .*****-  .*****-
      ******-  -*****- .**#@@@@@@@@    :@:=%.    =#=-+#-  .%@@@#**: :*****=  -*****+
     :******+  +*****= :**%@@@@@@@@-    -%%:     @-   +%   *@@@%**: -*****+  +******-
     +*******. ******+ -**#@@@@@*-.      ..      #*. .#*   #@@@%**- +******  *******+
-===+**+*****-.***+***.=*#%%%%%:  .=++=.          -+++-   =%%%%%#*= ***+***.:*****+**+===-
:---:.    -******. .*****+@@@@:  :@-  -@:   -#*+++    .:+%@@@@@@@*****.  ******-    .:---:
           -*****   +****-#@@@.  =@....@=   *#.    . .%@@@@@@@@@#****+   +****-
           .****+   =****:=@@@=  .#*--+#    .=***- :  #@@@@@@@@@-****=   =****.
            +***=   :****. %@@@+.  .--.         .@-: .%@@@@@@@@* ****-   -***+
            =***:   .****  -@@@@@*=::::=++. +*++**..:#@@@@@@@@%. ****.   :***=
            :***.    ****   *@@@@@@@@@@@@@%+-....:-*%@@@@@@@@@=  +***     ***-
             ***     +**+    #@@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@+   =**+     +**.
             -+-     =**=    .@@@*@@@@@@@@@@@@@@@@@@@@@@@@@@+    -**=     -+=
                     :**-     *%@%+%@@@@@@@@@@@@@@@@@@@@@@@%     -**-
                      ::      +*#@@##%@@@@@@@@@@@@@@@@@@@@#+      ::
                              =****%@%%@@@@@@@@@@@@@@@@%#**=
                              -*** .+%@@@@@@@@@@@@@@@#= +**-
                              :**+    :=*%@@@@@@%%*=.   =**:
                              .**=         .::..        -**.
\e[0m"

echo "                              =============================="
echo "                              --- Welcome to OpenVoiceOS ---"
echo "                               raspOVOS development Edition"
echo "                              =============================="
echo ""
echo ""
echo "OVOS Tool COMMANDs:"
echo "  ovos-config            Manage your local OVOS configuration files"
echo "  ovos-listen            Activate the microphone to listen for a command"
echo "  ovos-speak  <phrase>   Have OVOS speak a phrase to the user"
echo "  ovos-say-to <phrase>   Send an utterance to OVOS as if spoken by a user"
echo "  ovos-simple-cli        Chat with your device through the terminal"
echo "  ovos-docs-viewer       OVOS documentation viewer util"
echo
echo "OVOS packages utils:"
echo "  ovos-pip                Install ovos packages using /etc/mycroft/constraints.txt"
echo "  ovos-update             Update all OVOS and skill-related packages"
echo "  ovos-freeze             Export installed OVOS packages to requirements.txt"
echo "  ovos-outdated           List outdated OVOS and skill-related packages"
echo
echo "OVOS Log Viewer:"
echo "  ovos-logs [COMMAND] --help      Small tool to help navigate the logs"
echo "  ologs                           View all logs realtime"
echo
echo "Misc Helpful COMMANDs:"
echo "  ovos-status             List OVOS-related systemd services"
echo "  ovos-server-status      Check live status of OVOS public servers"
echo "  ovos-manual             OVOS technical manual in your terminal"
echo "  ovos-skills-info        Skills documentation in your terminal"
echo "  ovos-help               Show this message"
echo