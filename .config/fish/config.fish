# Minimal entrypoint: loads conf.d automatically; keep it clean.
# Put user customization in conf.d/*.fish and functions/*.fish

# Make sure interactive-only things don't run in non-interactive shells
if not status is-interactive
  exit
end
