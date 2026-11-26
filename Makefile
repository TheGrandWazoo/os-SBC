PLUGIN_NAME=		sbc
PLUGIN_VERSION=		1.0.0
PLUGIN_DEVEL=		yes
PLUGIN_COMMENT=		SIP Session Border Controller (Kamailio and rtpproxy)
PLUGIN_DEPENDS=		kamailio rtpproxy
PLUGIN_MAINTAINER=	thegrandwazoo@ksatechnologies.com
PLUGIN_WWW=		https://github.com/TheGrandWazoo/os-SBC

.include "../../Mk/plugins.mk"
