# Setting up SPARK on his PC

For Oleg, on site. Allow 45 minutes: about 15 for the install, then the first chat, his company setup and a
short walk-through.

## Bring or check before you go

- **The zip.** Download it on his PC from
  https://github.com/Aer0o/spark-kit/releases/latest/download/SPARK.zip, or bring `dist/SPARK.zip` on a USB stick.
- **His Windows password.** Installing LibreOffice and the other programs shows "Do you want to allow this app
  to make changes?". If his account isn't an administrator, an admin password is needed.
- **His Claude login** (claude.ai, Pro plan), already signed in to the Claude desktop app.
- **Internet, and about 3 GB of free disk space.** LibreOffice is the big download.
- Two or three emails he wrote himself, a recent quote, and his logo file. The setup interview uses them.

## 1. Check the basics (5 min)

1. Update the Claude desktop app (its menu, then check for updates) and restart it.
2. Open the **Code** tab and make sure it starts a session. In the session's environment selector, pick
   **Local**, not Cloud.
3. Open PowerShell and run `winget --version`. If it says "not recognized", install **App Installer** from the
   Microsoft Store first.
4. Note the Windows version (Settings > System > About). Windows 10 22H2 or 11 is fine.

## 2. Run the installer (10-15 min)

1. Put the zip in `Documents`. Right-click it > **Properties** > tick **Unblock** > OK.
2. Right-click > **Extract All** into `Documents\SPARK`. Keep this folder: Fix SPARK lives here.
3. Double-click **Install SPARK**.
   - "Windows protected your PC": click **More info** > **Run anyway**.
   - It lists the programs it will install. Type **Y**, then Enter.
   - Click **Yes** on each "allow this app to make changes" prompt. LibreOffice takes the longest; the
     window may sit still for a few minutes.
4. Read the result before closing:
   - **"All done"** and every line `[ OK ]`: carry on.
   - Any `[FAIL]`: run **Fix SPARK** once. If it still fails, photograph the screen. The full log is in
     `%USERPROFILE%\.claude\spark\install-report.txt`.
   - "Claude's settings file could not be read": nothing was changed. Open
     `%USERPROFILE%\.claude\settings.json`, fix the JSON (usually a stray comma), and run Install again.
5. **Quit Claude completely.** Right-click the Claude icon by the clock > **Quit**, then start it again.
   Claude only sees the new programs and SPARK after a full restart.

## 3. First chat: prove it works (5 min)

1. Make a work folder, for example `Documents\Jobs`. In the Code tab, open that folder, environment **Local**.
2. Set the model and effort in the model picker. See section 6.
3. Type `hi`. The first reply should start with a line saying **SPARK is ready** and then offer the
   five-minute setup. That line proves the plugin and its hooks loaded.
   - **No SPARK line:** see "SPARK didn't load" in section 7.
4. Ask: `Make a one-page test Word document with a title and a short table, save it in this folder.` A .docx
   should appear in `Documents\Jobs`. Open it in Word.

## 4. The setup interview, with him (10 min)

Say `set up SPARK` and let him answer. Claude asks one thing at a time:
- company details
- licence and HST numbers
- the work he does and who he bids to
- standard exclusions (drop in an old quote and Claude pulls them out)
- quote validity and payment terms
- brand colour and logo (drop the logo file in)
- who signs

Then say `learn how I write` and paste two or three of his own emails.

Check the result in `%USERPROFILE%\.claude\spark\profile.md`. If he had SPARK 1, his old profile was
carried over and Claude skips the interview.

## 5. Show him how to use it (10 min)

Open `Documents\SPARK\What to say.txt` together and try two real jobs he has on now, for example a
report from his notes and a quote check. Point out:
- **Drag files into the chat**, or name the file in the folder.
- **One job per chat.** Start a new chat for each job. Long chats use his limit fastest.
- **Claude saves every changed file as "v2"** and never overwrites his original.
- **"Undo that"** gets the old file back: SPARK keeps a copy of every document it touches, for 30 days.
- **Part numbers and prices come with a source.** If one doesn't, ask "where did that come from?"
- **When something breaks,** double-click **Fix SPARK** and restart Claude.

## 6. Model and thinking on the Pro plan (the biggest lever)

His plan has a 5-hour limit and a weekly limit, shared between claude.ai and Claude Code. On Pro he can hit
a model-specific Opus limit and keep working by switching model. The three things that use his limit fastest:

1. **Effort.** He runs near-max thinking. In the real tests a one-page report used about 47 steps before I
   optimised the kit. Thinking is paid on every step. Suggest to him:
   - **High** for tenders, quote checks and anything with money.
   - **Medium** for emails, proofreading and small edits.
   - **Max** only when a hard job got something wrong.

   SPARK saves "high" as his Opus 5.5 default, and the picker overrides it per chat.
2. **Model.** Opus for tender review and quote checks. A cheaper model (Sonnet) should handle emails,
   formatting and PDF-to-Excel well; that's my expectation, not something I tested. If he hits "Opus limit", switching model lets him keep working.
3. **Long chats.** Each step re-reads the whole chat. SPARK suggests a new chat after 20 messages and
   summarises long chats at 200k tokens, but "one job per chat" is the habit that matters.

Show him where his usage is shown (Settings > Usage on claude.ai, or `/usage` in a chat) so he can see what a
job costs.

Optional, also in claude.ai Customize > Connectors: switch off connectors he doesn't use (Gmail, Drive...).
Each one adds a little to every chat.

## 7. If something goes wrong

| What you see | What to do |
|---|---|
| No "SPARK is ready" line in the first chat | Quit Claude fully and reopen. Still nothing: check `settings.json` has `"spark@spark": true` and the `spark` marketplace (section 8). Then the manual install below. |
| Claude says Word or PDF tools are missing | Run **Fix SPARK**, then quit and reopen Claude. |
| `[FAIL] LibreOffice` (or another program) | Run **Fix SPARK**. If winget itself fails, install that program from its website, then run Fix SPARK so the PATH is set. |
| "Python was not found; run without arguments to install from the Microsoft Store" | Run **Fix SPARK**. It puts the real Python ahead of the Store shortcut. Quit and reopen Claude. |
| Claude asks permission for every command | Check the session's mode is "Accept edits", not "Ask". |
| A hook error shows in the chat | Look at `%USERPROFILE%\.claude\spark\hook-errors.log` and send it to Oleg. A failing hook doesn't stop his work. |
| He wants it gone | Double-click **Uninstall SPARK**. His files stay in `.claude\spark`. |

**Manual install if the plugin didn't download.** Node is installed by then, so in PowerShell:
```
npm install -g @anthropic-ai/claude-code
claude plugin marketplace add https://github.com/Aer0o/spark-kit.git
claude plugin install spark@spark
```
Then quit and reopen the desktop app. (Tested on Oleg's PC in a clean config; the plugin commands need no login.)

## 8. What "done" looks like

- [ ] Install ended with "All done", every line `[ OK ]`.
- [ ] The first chat says "SPARK is ready".
- [ ] A test Word file was created in his work folder and opens in Word.
- [ ] `profile.md` and `voice.md` are filled in.
- [ ] He did one real job himself, start to finish.
- [ ] Effort and model are set the way he agreed (section 6).
- [ ] `Documents\SPARK` (with Fix SPARK) is somewhere he can find it.

To see what was installed, `settings.json` should contain, among his own settings:
```
"extraKnownMarketplaces": { "spark": { "source": { "source": "git", "url": "https://github.com/Aer0o/spark-kit.git" }, "autoUpdate": true } },
"enabledPlugins": { "spark@spark": true }
```
The full list of what SPARK installs and changes is in `docs/INVENTORY.md`.

## 9. After the visit

Updates reach him on their own. Push a change under `plugins/spark/` to GitHub and his next chat picks it
up (see `MAINTAINING.md`). If he reports a problem, ask for `install-report.txt` and `hook-errors.log` from
`%USERPROFILE%\.claude\spark\`.
