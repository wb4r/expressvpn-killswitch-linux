# expressvpn-killswitch
Tested in debian 4.6.4 x64 and expressvpn version 1.2.0

- Make it executable<br />
`sudo chmod+x expressvpn-killswitch.sh` <br />
- Execute with sudo privileges or will fail<br />
`sudo expressvpn-killswitch.sh` <br />
- Monitor the log file constantly<br />
`tail -f dailyfile.log` <br />
- The script creates new files for every day where a disconnection has happened<br />
- Each file will have the day.log as name<br />
- Any feedback or improvement is welcome<br />
