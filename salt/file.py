

def replace(path,
            pattern,
            repl,
            count=0,
            flags=0,
            bufsize=1,
            append_if_not_found=False,
            prepend_if_not_found=False,
            not_found_content=None,
            backup='.bak',
            dry_run=False,
            search_only=False,
            show_changes=True,):
    print ("Hello")
    if not os.path.exists(path):
        raise SaltInvocationError('File not found: {0}'.format(path))
    if not salt.utils.istextfile(path):
        raise SaltInvocationError(
            'Cannot perform string replacements on a binary file: {0}'.format(path))
    if search_only and (append_if_not_found or prepend_if_not_found):
        raise SaltInvocationError(
            'Choose between search_only and ''append/prepend_if_not_found')
    if append_if_not_found and prepend_if_not_found:
        raise SaltInvocationError(
            'Choose between append or ''prepend_if_not_found')
    flags_num = _get_flags(flags)
    cpattern = re.compile(pattern, flags_num)
    if bufsize == 'file':
        bufsize = os.path.getsize(path)
    # Search the file; track if any changes have been made for the
    # return val
    has_changes = False
    orig_file = []  # used if show_changes
    new_file = []  # used if show_changes
    if not salt.utils.is_windows():
        pre_user = get_user(path)
        pre_group = get_group(path)
        pre_mode = __salt__['config.manage_mode'](get_mode(path))
    # Avoid TypeErrors by forcing repl to be a string
    repl = str(repl)
    try:
        fi_file = fileinput.input(path,
                                  inplace=not dry_run,
                                  backup=False if dry_run else backup,
                                  bufsize=bufsize,
                                  mode='rb')
        found = False
        for line in fi_file:

            if search_only:
                # Just search; bail as early as a match is found
                result = re.search(cpattern, line)

                if result:
                    return True
                    # `finally` block handles file closure
            else:
                result, nrepl = re.subn(cpattern, repl, line, count)

                # found anything? (even if no change)
                if nrepl > 0:
                    found = True

                # Identity check each potential change until one
                # change is made
                if has_changes is False and result is not line:
                    has_changes = True

                if show_changes:
                    orig_file.append(line)
                    new_file.append(result)
                if not dry_run:
                    print(result, end='', file=sys.stdout)
    finally:
        fi_file.close()

    if not found and (append_if_not_found or prepend_if_not_found):
        if not_found_content is None:
            not_found_content = repl
        if prepend_if_not_found:
            new_file.insert(not_found_content + '\n')
        else:
            # append_if_not_found
            # Make sure we have a newline at the end of the file
            if 0 != len(new_file):
                if not new_file[-1].endswith('\n'):
                    new_file[-1] += '\n'
            new_file.append(not_found_content + '\n')
        has_changes = True
        if not dry_run:
            # backup already done in filter part
            # write new content in the file while avoiding partial
            # reads
            try:
                f = salt.utils.atomicfile.atomic_open(path, 'wb')
                for line in new_file:
                    f.write(line)
            finally:
                f.close()
    if not dry_run and not salt.utils.is_windows():
        check_perms(path, None, pre_user, pre_group, pre_mode)
    if show_changes:
        return ''.join(difflib.unified_diff(orig_file, new_file))
    return has_changes
