from fabric.api import local, run, env, put

# remote machine details


# path to deploy code
env.deploy_project_root = '/srv/web_app/'
# deifining the git repository


def production():
    """Defines production environment"""
    env.hosts = ['192.168.122.196']
    env.user = 'dk'
    env.password = 'dk'
    env.base_dir = "/var/web_app"
    env.app_name = "app"
    env.domain_name = "192.168.122.196"
    env.domain_path = "%(base_dir)s/%(domain_name)s" % {
        'base_dir': env.base_dir, 'domain_name': env.domain_name}
    env.current_path = "%(domain_path)s/current" % {
        'domain_path': env.domain_path}
    env.releases_path = "%(domain_path)s/releases" % {
        'domain_path': env.domain_path}
    env.shared_path = "%(domain_path)s/shared" % {
        'domain_path': env.domain_path}
    env.git_clone = "git@github.com:hellodk/ncpr.git"
    env.env_file = "deploy/production.txt"


def permissions():
    """Make the release group-writable"""
    sudo("chmod -R g+w %(domain_path)s" % {'domain_path': env.domain_path})
    sudo("chown -R www-data:www-data %(domain_path)s" %
         {'domain_path': env.domain_path})


def releases():
    """List a releases made"""
    env.releases = sorted(
        run('ls -x %(releases_path)s' % {'releases_path': env.releases_path}).split())
    if len(env.releases) >= 1:
        env.current_revision = env.releases[-1]
        env.current_release = "%(releases_path)s/%(current_revision)s" % {
            'releases_path': env.releases_path, 'current_revision': env.current_revision}
    if len(env.releases) > 1:
        env.previous_revision = env.releases[-2]
        env.previous_release = "%(releases_path)s/%(previous_revision)s" % {
            'releases_path': env.releases_path, 'previous_revision': env.previous_revision}

def setup():
    """Prepares one or more servers for deployment"""
    run("mkdir -p %(domain_path)s/{releases,shared}" % { 'domain_path':env.domain_path })
    run("mkdir -p %(shared_path)s/{system,log,index}" % { 'shared_path':env.shared_path })
    permissions()

def checkout():
    """Checkout code to the remote servers"""
    from time import time
    env.current_release = "%(releases_path)s/%(time).0f" % { 'releases_path':env.releases_path, 'time':time() }
    run("cd %(releases_path)s; git clone -q -o deploy --depth 1 %(git_clone)s %(current_release)s" % { 'releases_path':env.releases_path, 'git_clone':env.git_clone, 'current_release':env.current_release })

def update():
    """Copies your project and updates environment and symlink"""
    update_code()
    update_env()
    symlink()
    permissions()

def update_code():
    """Copies your project to the remote servers"""
    checkout()
    permissions()

def permissions():
    """Make the release group-writable"""
    sudo("chmod -R g+w %(domain_path)s" % { 'domain_path':env.domain_path })
    sudo("chown -R www-data:www-data %(domain_path)s" % { 'domain_path':env.domain_path })

def checkout():
    """Checkout code to the remote servers"""
    from time import time
    env.current_release = "%(releases_path)s/%(time).0f" % {
        'releases_path': env.releases_path, 'time': time()}
    run("cd %(releases_path)s; git clone -q -o deploy --depth 1 %(git_clone)s %(current_release)s" %
        {'releases_path': env.releases_path, 'git_clone': env.git_clone, 'current_release': env.current_release})
