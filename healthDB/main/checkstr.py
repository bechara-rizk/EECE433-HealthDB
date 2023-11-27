


def checkstr(string):
    if "'" in string:
        #remove all apostrophes
        string = string.replace("'", "")
        return False
    if "\\" in string:
        #remove all backslashes
        string = string.replace("\\", "")
        return False
    if '"' in string:
        #remove all double quotes
        string = string.replace('"', "")
        return False
    if ";" in string:
        #remove all semicolons
        string = string.replace(";", "")
        return False
    if ":" in string:
        #remove all colons
        string = string.replace(":", "")
        return False
    if ">" in string:
        #remove all greater than signs
        string = string.replace(">", "")
        return False
    if "<" in string:
        #remove all less than signs
        string = string.replace("<", "")
        return False
    return True

def cleanstr(string):
    if "'" in string:
        #remove all apostrophes
        string = string.replace("'", "")
    if "\\" in string:
        #remove all backslashes
        string = string.replace("\\", "")
    if '"' in string:
        #remove all double quotes
        string = string.replace('"', "")
    if ";" in string:
        #remove all semicolons
        string = string.replace(";", "")
    if ":" in string:
        #remove all colons
        string = string.replace(":", "")
    if ">" in string:
        #remove all greater than signs
        string = string.replace(">", "")
    if "<" in string:
        #remove all less than signs
        string = string.replace("<", "")
    return string