
resource "nomad_csi_volume_registration" "arcade-config" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "arcade-config"
  name        = "arcade-config"
  external_id = "arcade/config"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "arcade-data" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "arcade-data"
  name        = "arcade-data"
  external_id = "arcade/data"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "docker_registry" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "docker_registry"
  name        = "docker_registry"
  external_id = "docker_registry"

  capability {
    access_mode     = "multi-node-single-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "vaultwarden" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "vaultwarden"
  name        = "vaultwarden"
  external_id = "vaultwarden"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "n8n" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "n8n"
  name        = "n8n"
  external_id = "n8n"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "flaresolverr" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "flaresolverr"
  name        = "flaresolverr"
  external_id = "flaresolverr"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "motioneye-shared" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "motioneye-shared"
  name        = "motioneye-shared"
  external_id = "motioneye/shared"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "motioneye-etc" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "motioneye-etc"
  name        = "motioneye-etc"
  external_id = "motioneye/etc"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "grafana" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "grafana"
  name        = "grafana"
  external_id = "grafana"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "hass" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "hass"
  name        = "hass"
  external_id = "hass"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "influxdb-config" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "influxdb-config"
  name        = "influxdb-config"
  external_id = "influxdb/config"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "influxdb-data" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "influxdb-data"
  name        = "influxdb-data"
  external_id = "influxdb/data"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "matter" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "matter"
  name        = "matter"
  external_id = "matter"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "mongo" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "mongo"
  name        = "mongo"
  external_id = "mongo"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "mosquitto-config" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "mosquitto-config"
  name        = "mosquitto-config"
  external_id = "mosquitto/config"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "mosquitto-data" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "mosquitto-data"
  name        = "mosquitto-data"
  external_id = "mosquitto/data"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "mosquitto-log" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "mosquitto-log"
  name        = "mosquitto-log"
  external_id = "mosquitto/log"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "loki" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "loki"
  name        = "loki"
  external_id = "loki"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "plex" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "plex"
  name        = "plex"
  external_id = "plex"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "postgres" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "postgres"
  name        = "postgres"
  external_id = "postgres"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "prowlarr" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "prowlarr"
  name        = "prowlarr"
  external_id = "prowlarr"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "radarr" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "radarr"
  name        = "radarr"
  external_id = "radarr"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}


resource "nomad_csi_volume_registration" "sonarr" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "sonarr"
  name        = "sonarr"
  external_id = "sonarr"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}


resource "nomad_csi_volume_registration" "jellyfin" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "jellyfin"
  name        = "jellyfin"
  external_id = "jellyfin"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "sabnzbd" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "sabnzbd"
  name        = "sabnzbd"
  external_id = "sabnzbd"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "transmission" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "transmission"
  name        = "transmission"
  external_id = "transmission"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "unifi" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "unifi"
  name        = "unifi"
  external_id = "unifi"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "wikijs" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "wikijs"
  name        = "wikijs"
  external_id = "wikijs"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "media" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "media"
  name        = "media"
  external_id = "media"

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "downloads" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "downloads"
  name        = "downloads"
  external_id = "media/downloads"

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "torrents" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "torrents"
  name        = "torrents"
  external_id = "media/downloads/torrents"

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "certs" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "certs"
  name        = "certs"
  external_id = "certs"

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }
}

resource "nomad_csi_volume_registration" "traefik-logs" {

  depends_on  = [nomad_job.core_services]
  plugin_id   = "nfs"
  volume_id   = "traefik-logs"
  name        = "traefik-logs"
  external_id = "traefik/logs"

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }
}

