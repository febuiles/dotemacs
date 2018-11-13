(cond ((string= system-type "gnu/linux")

       (set-face-attribute 'default nil :height 155)
       (global-set-key [(control -)] 'font-smaller)
       (global-set-key [(control \+)] 'font-larger)
       (global-set-key [XF86AudioRaiseVolume] 'shell))

      ((string= system-type "darwin")

       (set-default-font "-unknown-Inconsolata-normal-normal-normal-*-*-*-*-*-m-0-iso10646-1")
       (set-face-attribute 'default nil :height 230)))
