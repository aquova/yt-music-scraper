import htmlparser, os, sequtils, strformat, strutils, xmltree

const HTML_NAME_TAG = "yt-formatted-string"

proc main() =
    if paramCount() != 2:
        echo("yt-music-parser file.html path/to/audio/files")
        return

    let html_filename = paramStr(1)
    if not fileExists(html_filename):
        echo("Unable to find ", html_filename)
        return

    let audio_path = paramStr(2)
    if not dirExists(audio_path):
        echo("Unable to find ", audio_path)
        return

    var song_names: seq[string]
    let html = loadHtml(html_filename)
    for a in html.findAll("a"):
        let classes = a.attr("class")
        let link = a.attr("href")
        if classes.contains(HTML_NAME_TAG) and link.contains("watch"):
            song_names.add(a.innerText())
            echo(a.innerText())

    audio_path.setCurrentDir()
    let audio_files = toSeq(walkFiles("*.m4a"))

    assert(audio_files.len() == song_names.len(), &"Number of found titles does not equal number of files. Files: {audio_files.len()},  songs: {song_names.len()}")
    for i in 0..<audio_files.len():
        var new_name = &"{i + 1}-{song_names[i]}.m4a"
        new_name = new_name.replace(",", "")
        new_name = new_name.replace(":", " -")
        new_name = new_name.replace("?", "")
        new_name = new_name.replace("/", "-")
        new_name = new_name.replace("*", "")

        echo(&"{audio_files[i]} -> {new_name}")
        audio_files[i].moveFile(new_name)

when isMainModule:
    main()
