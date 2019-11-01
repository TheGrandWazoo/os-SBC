{# Macro import #}
{% if not helpers.empty('OPNsense.SBC.general.enabled') %}
asterisk_enable="YES"
{% else %}
asterisk_enable="NO"
{% endif %}
