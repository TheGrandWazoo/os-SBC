{#/

Copyright (C) 2018-2019 Kevin Scott Adams
OPNsense® is Copyright © 2014 – 2015 by Deciso B.V.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

#}

<script>

    $( document ).ready(function() {

        var data_get_map = {'frm_sbc':"/api/sbc/settings/get"};

        // load initial data
        mapDataToFormUI(data_get_map).done(function(){
            formatTokenizersUI();
            $('.selectpicker').selectpicker('refresh');
            // request service status on load and update status box
            ajaxCall(url="/api/sbc/service/status", sendData={}, callback=function(data,status) {
                updateServiceStatusUI(data['status']);
            });
        });

        /***********************************************************************
         * link grid actions
         **********************************************************************/

        $("#grid-transports").UIBootgrid(
            {   search:'/api/sbc/settings/searchTransports',
                get:'/api/sbc/settings/getTransport/',
                set:'/api/sbc/settings/setTransport/',
                add:'/api/sbc/settings/addTransport/',
                del:'/api/sbc/settings/delTransport/',
                toggle:'/api/sbc/settings/toggleTransport/',
                options: {
                    rowCount:[10,25,50,100,500,1000]
                }
            }
        );

        $("#grid-aors").UIBootgrid(
            {   search:'/api/sbc/settings/searchAoRs',
                get:'/api/sbc/settings/getAoR/',
                set:'/api/sbc/settings/setAoR/',
                add:'/api/sbc/settings/addAoR/',
                del:'/api/sbc/settings/delAoR/',
                toggle:'/api/sbc/settings/toggleAoR/',
                options: {
                    rowCount:[10,25,50,100,500,1000]
                }
            }
        );

        $("#grid-endpoints").UIBootgrid(
            {   search:'/api/sbc/settings/searchEndpoints',
                get:'/api/sbc/settings/getEndpoint/',
                set:'/api/sbc/settings/setEndpoint/',
                add:'/api/sbc/settings/addEndpoint/',
                del:'/api/sbc/settings/delEndpoint/',
                toggle:'/api/sbc/settings/toggleEndpoint/',
                options: {
                    rowCount:[10,25,50,100,500,1000]
                }
            }
        );

        $("#grid-authentications").UIBootgrid(
            {   search:'/api/sbc/settings/searchAuthentications',
                get:'/api/sbc/settings/getAuthentication/',
                set:'/api/sbc/settings/setAuthentication/',
                add:'/api/sbc/settings/addAuthentication/',
                del:'/api/sbc/settings/delAuthentication/',
                options: {
                    rowCount:[10,25,50,100,500,1000]
                }
            }
        );

        $("#grid-registrations").UIBootgrid(
            {   search:'/api/sbc/settings/searchRegistrations',
                get:'/api/sbc/settings/getRegistration/',
                set:'/api/sbc/settings/setRegistration/',
                add:'/api/sbc/settings/addRegistration/',
                del:'/api/sbc/settings/delRegistration/',
                options: {
                    rowCount:[10,25,50,100,500,1000]
                }
            }
        );

        $("#grid-codecs").UIBootgrid(
            {   search:'/api/sbc/settings/searchCodecs',
                get:'/api/sbc/settings/getCodec/',
                set:'/api/sbc/settings/setCodec/',
                add:'/api/sbc/settings/addCodec/',
                del:'/api/sbc/settings/delCodec/',
                options: {
                    rowCount:[10,25,50,100,500,1000]
                }
            }
        );
/*
		$("#endpoint\\.disallow").change(function() {
			var $element = $(this).find("option:selected");
			if ($("#endpoint\\.disallow").find(":selected").length > 1) {
				var $second = $("#endpoint\\.disallow").find(":selected").eq(-2);
				$second.after($element);
			} else {
				$("#endpoint\\.disallow").prepend($element);
			}
		});


        // hook into on-show event for dialog to extend layout.
        $('#DialogTransport').on('shown.bs.modal', function (e) {
            $("#transport\\.expression").change(function(){
                var service_id = 'table_' + $(this).val();
                $(".expression_table").hide();
                // $(".table_"+$(this).val()).show();
                $("."+service_id).show();
            });
            $("#transport\\.expression").change();
        })

        // hook into on-show event for dialog to extend layout.
        $('#DialogAoR').on('shown.bs.modal', function (e) {
            $("#aor\\.type").change(function(){
                var service_id = 'table_' + $(this).val();
                $(".type_table").hide();
                // $(".table_"+$(this).val()).show();
                $("."+service_id).show();
            });
            $("#aor\\.type").change();
        })

        // hook into on-show event for dialog to extend layout.
        $('#DialogEndpoint').on('shown.bs.modal', function (e) {
            $("#endpoint\\.enabled").change(function(){
                var service_id = 'table_transport_' + $(this).is(':checked');
                $(".transport_table").hide();
                $("."+service_id).show();
            });
            $("#endpoint\\.").change();

            $("#endpoint\\.persistence").change(function(){
                var persistence_id = 'table_persistence_' + $(this).val();
                $(".persistence_table").hide();
                $("."+persistence_id).show();
            });
            $("#endpoint\\.persistence").change();
        })

        // hook into on-show event for dialog to extend layout.
        $('#DialogAuthentication').on('shown.bs.modal', function (e) {
            $("#authentication\\.mode").change(function(){
                var service_id = 'table_' + $(this).val();
                $(".mode_table").hide();
                $("."+service_id).show();
            });
            $("#authentication\\.mode").change();

            // show/hide SSL offloading
            $("#authentication\\.ssl_enabled").change(function(){
                var service_id = 'table_ssl_' + $(this).is(':checked');
                $(".table_ssl").hide();
                $("."+service_id).show();
            });
            $("#authentication\\.ssl_enabled").change();

            // show/hide advanced SSL settings
            $("#authentication\\.ssl_advancedEnabled").change(function(){
                var service_id = 'table_ssl_advanced_' + $(this).is(':checked');
                $(".table_ssl_advanced").hide();
                $("."+service_id).show();
            });
            $("#authentication\\.ssl_advancedEnabled").change();
        })

        // hook into on-show event for dialog to extend layout.
        $('#DialogRegistration').on('shown.bs.modal', function (e) {
            $("#registration\\.type").change(function(){
                var service_id = 'table_' + $(this).val();
                $(".type_table").hide();
                // $(".table_"+$(this).val()).show();
                $("."+service_id).show();
            });
            $("#registration\\.type").change();
        })
*/
        /***********************************************************************
         * Commands
         **********************************************************************/

        // Reconfigure sbc - activate changes
        $('[id*="reconfigureAct"]').each(function(){
            $(this).click(function(){
                // set progress animation
                $('[id*="reconfigureAct_progress"]').each(function(){
                    $(this).addClass("fa fa-spinner fa-pulse");
                });
                ajaxCall(url="/api/sbc/service/reconfigure", sendData={}, callback=function(data,status) {
                    if (status != "success" || data['status'] != 'ok') {
                        BootstrapDialog.show({
                            type: BootstrapDialog.TYPE_WARNING,
                            title: "{{ lang._('Error reconfiguring HAProxy') }}",
                            message: data['status'],
                            draggable: true
                        });
                    }
                    // when done, disable progress animation
                    $('[id*="reconfigureAct_progress"]').each(function(){
                        $(this).removeClass("fa fa-spinner fa-pulse");
                    });
                });
            });
        });

        // Test configuration file
        $('[id*="configtestAct"]').each(function(){
            $(this).click(function(){

            // set progress animation
            $('[id*="configtestAct_progress"]').each(function(){
                $(this).addClass("fa fa-spinner fa-pulse");
            });

            ajaxCall(url="/api/sbc/service/configtest", sendData={}, callback=function(data,status) {
                // when done, disable progress animation
                $('[id*="configtestAct_progress"]').each(function(){
                    $(this).removeClass("fa fa-spinner fa-pulse");
                });

                if (data['result'].indexOf('ALERT') > -1) {
                    BootstrapDialog.show({
                        type: BootstrapDialog.TYPE_DANGER,
                        title: "{{ lang._('HAProxy config contains critical errors') }}",
                        message: data['result'],
                        draggable: true
                    });
                } else if (data['result'].indexOf('WARNING') > -1) {
                    BootstrapDialog.show({
                        type: BootstrapDialog.TYPE_WARNING,
                        title: "{{ lang._('HAProxy config contains minor errors') }}",
                        message: data['result'],
                        draggable: true
                    });
                } else {
                    BootstrapDialog.show({
                        type: BootstrapDialog.TYPE_WARNING,
                        title: "{{ lang._('HAProxy config test result') }}",
                        message: "{{ lang._('Your HAProxy config contains no errors.') }}",
                        draggable: true
                    });
                }
            });
            });
        });

        // form save event handlers for all defined forms
        $('[id*="save_"]').each(function(){
            $(this).click(function(){
                var frm_id = $(this).closest("form").attr("id");
                var frm_title = $(this).closest("form").attr("data-title");

                // set progress animation
                $("#"+frm_id+"_progress").addClass("fa fa-spinner fa-pulse");

                // save data for tab
                saveFormToEndpoint(url="/api/sbc/settings/set",formid=frm_id,callback_ok=function() {

                    // on correct save, perform reconfigure
                    ajaxCall(url="/api/sbc/service/reconfigure", sendData={}, callback=function(data,status) {
                        if (status != "success" || data['status'] != 'ok') {
                            BootstrapDialog.show({
                                type: BootstrapDialog.TYPE_WARNING,
                                title: "{{ lang._('Error reconfiguring SBC') }}",
                                message: data['status'],
                                draggable: true
                            });
                        } else {
                            ajaxCall(url="/api/sbc/service/status", sendData={}, callback=function(data,status) {
                                updateServiceStatusUI(data['status']);
                            });
                        }
                        // when done, disable progress animation.
                        $("#"+frm_id+"_progress").removeClass("fa fa-spinner fa-pulse");
                    });

                });
            });
        });

        // update history on tab state and implement navigation
        if (window.location.hash != "") {
            $('a[href="' + window.location.hash + '"]').click()
        }
        $('.nav-tabs a').on('shown.bs.tab', function (e) {
            history.pushState(null, null, e.target.hash);
        });

    });

</script>

<ul class="nav nav-tabs" role="tablist" id="maintabs">
    {# manually add tabs #}
    <li class="active"><a data-toggle="tab" href="#introduction"><b>{{ lang._('Introduction') }}</b></a></li>

    <li role="presentation" class="dropdown">
        <a data-toggle="dropdown" href="#" class="dropdown-toggle pull-right visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" role="button">
            <b><span class="caret"></span></b>
        </a>
        <a data-toggle="tab" onclick="$('#{% if showIntro|default('0')=='1' %}transports-introduction{% else %}transports-tab{% endif %}').click();" class="visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" style="border-right:0px;"><b>{{ lang._('Transports') }}</b></a>
        <ul class="dropdown-menu" role="menu">
            {% if showIntro|default('0')=='1' %}
            <li><a data-toggle="tab" id="transports-introduction" href="#subtab_sbc-transports-introduction">{{ lang._('Introduction') }}</a></li>
            {% endif %}
            <li><a data-toggle="tab" id="transports-tab" href="#transports">{{ lang._('Transports') }}</a></li>
        </ul>
    </li>

    <li role="presentation" class="dropdown">
        <a data-toggle="dropdown" href="#" class="dropdown-toggle pull-right visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" role="button">
            <b><span class="caret"></span></b>
        </a>
        <a data-toggle="tab" onclick="$('#{% if showIntro|default('0')=='1' %}aors-introduction{% else %}aors-tab{% endif %}').click();" class="visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" style="border-right:0px;"><b>{{ lang._('AORS') }}</b></a>
        <ul class="dropdown-menu" role="menu">
            {% if showIntro|default('0')=='1' %}
            <li><a data-toggle="tab" id="aors-introduction" href="#subtab_sbc-aors-introduction">{{ lang._('Introduction') }}</a></li>
            {% endif %}
            <li><a data-toggle="tab" id="aors-tab" href="#aors">{{ lang._('AORs') }}</a></li>
        </ul>
    </li>

    <li role="presentation" class="dropdown">
        <a data-toggle="dropdown" href="#" class="dropdown-toggle pull-right visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" role="button">
            <b><span class="caret"></span></b>
        </a>
        <a data-toggle="tab" onclick="$('#{% if showIntro|default('0')=='1' %}endpoints-introduction{% else %}endpoints-tab{% endif %}').click();" class="visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" style="border-right:0px;"><b>{{ lang._('Endpoints') }}</b></a>
        <ul class="dropdown-menu" role="menu">
            {% if showIntro|default('0')=='1' %}
            <li><a data-toggle="tab" id="endpoints-introduction" href="#subtab_sbc-endpoints-introduction">{{ lang._('Introduction') }}</a></li>
            {% endif %}
            <li><a data-toggle="tab" id="endpoints-tab" href="#endpoints">{{ lang._('Endpoints') }}</a></li>
        </ul>
    </li>

    <li role="presentation" class="dropdown">
        <a data-toggle="dropdown" href="#" class="dropdown-toggle pull-right visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" role="button">
            <b><span class="caret"></span></b>
        </a>
        <a data-toggle="tab" onclick="$('#{% if showIntro|default('0')=='1' %}authentications-introduction{% else %}authentications-tab{% endif %}').click();" class="visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" style="border-right:0px;"><b>{{ lang._('Authentications') }}</b></a>
        <ul class="dropdown-menu" role="menu">
            {% if showIntro|default('0')=='1' %}
            <li><a data-toggle="tab" id="authentications-introduction" href="#subtab_sbc-authentications-introduction">{{ lang._('Introduction') }}</a></li>
            {% endif %}
            <li><a data-toggle="tab" id="authentications-tab" href="#authentications">{{ lang._('Authentications') }}</a></li>
        </ul>
    </li>

    <li role="presentation" class="dropdown">
        <a data-toggle="dropdown" href="#" class="dropdown-toggle pull-right visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" role="button">
            <b><span class="caret"></span></b>
        </a>
        <a data-toggle="tab" onclick="$('#{% if showIntro|default('0')=='1' %}registrations-introduction{% else %}registrations-tab{% endif %}').click();" class="visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" style="border-right:0px;"><b>{{ lang._('Registrations') }}</b></a>
        <ul class="dropdown-menu" role="menu">
            {% if showIntro|default('0')=='1' %}
            <li><a data-toggle="tab" id="registrations-introduction" href="#subtab_sbc-registrations-introduction">{{ lang._('Introduction') }}</a></li>
            {% endif %}
            <li><a data-toggle="tab" id="registrations-tab" href="#registrations">{{ lang._('Registrations') }}</a></li>
        </ul>
    </li>
    
    <li role="presentation" class="dropdown">
        <a data-toggle="dropdown" href="#" class="dropdown-toggle pull-right visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" role="button">
            <b><span class="caret"></span></b>
        </a>
        <a data-toggle="tab" onclick="$('#{% if showIntro|default('0')=='1' %}codecs-introduction{% else %}codecs-tab{% endif %}').click();" class="visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" style="border-right:0px;"><b>{{ lang._('Codecs') }}</b></a>
        <ul class="dropdown-menu" role="menu">
            {% if showIntro|default('0')=='1' %}
            <li><a data-toggle="tab" id="codecs-introduction" href="#subtab_sbc-codecs-introduction">{{ lang._('Introduction') }}</a></li>
            {% endif %}
            <li><a data-toggle="tab" id="codecs-tab" href="#codecs">{{ lang._('Codecs') }}</a></li>
        </ul>
    </li>

    {# add automatically generated tabs #}
    {% for tab in mainForm['tabs']|default([]) %}
        {% if tab['subtabs']|default(false) %}
        {# Tab with dropdown #}
        <li role="presentation" class="dropdown">
            <a data-toggle="dropdown" href="#" class="dropdown-toggle pull-right visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" role="button">
                <b><span class="caret"></span></b>
            </a>
            <a data-toggle="tab" onclick="$('#subtab_item_{{tab['subtabs'][0][0]}}').click();" class="visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" style="border-right:0px;"><b>{{tab[1]}}</b></a>
            <ul class="dropdown-menu" role="menu">
                {% for subtab in tab['subtabs']|default({})%}
                <li><a data-toggle="tab" id="subtab_item_{{subtab[0]}}" href="#subtab_{{subtab[0]}}">{{subtab[1]}}</a></li>
                {% endfor %}
            </ul>
        </li>
        {% else %}
        {# Standard Tab #}
        <li>
                <a data-toggle="tab" href="#tab_{{tab[0]}}">
                    <b>{{tab[1]}}</b>
                </a>
        </li>
        {% endif %}
    {% endfor %}

    <li role="presentation" class="dropdown">
        <a data-toggle="dropdown" href="#" class="dropdown-toggle pull-right visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" role="button">
            <b><span class="caret"></span></b>
        </a>
        <a data-toggle="tab" onclick="$('#{% if showIntro|default('0')=='1' %}advanced-introduction{% else %}errorfiles-tab{% endif %}').click();" class="visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block" style="border-right:0px;"><b>{{ lang._('Advanced') }}</b></a>
        <ul class="dropdown-menu" role="menu">
            {% if showIntro|default('0')=='1' %}
            <li><a data-toggle="tab" id="advanced-introduction" href="#subtab_sbc-advanced-introduction">{{ lang._('Introduction') }}</a></li>
            {% endif %}
            <li><a data-toggle="tab" id="errorfiles-tab" href="#errorfiles">{{ lang._('Error Messages') }}</a></li>
            <li><a data-toggle="tab" href="#luas">{{ lang._('Lua Scripts') }}</a></li>
            <li><a data-toggle="tab" href="#mapfiles">{{ lang._('Map Files') }}</a></li>
            <li><a data-toggle="tab" href="#cpus">{{ lang._('CPU Affinity Rules') }}</a></li>
        </ul>
    </li>
</ul>

<div class="content-box tab-content">
    <div id="introduction" class="tab-pane fade in active">
        <div class="col-md-12">
            <h1>{{ lang._('Quick Start Guide') }}</h1>
            <p>{{ lang._('Welcome to the SBC plugin! This plugin is designed to offer features and flexibility of an SBC using the Asterisk framework package.')}}</p>
            <p>{{ lang._('Note that you should configure the SBC plugin in the following order:') }}</p>
            <ul>
              <li>{{ lang._('Add %sTransports:%s All TCP and/or UDP transports on the public and private networks.') | format('<b>', '</b>') }}</li>
              <li>{{ lang._('Add %sAoRs:%s Address-of-Record (AOR)s to let the SBC know where to contact an endpoint.') | format('<b>', '</b>')}}</li>
              <li>{{ lang._('Add %sEndpoints:%s An endpoint is a phyiscal SIP phone or SIP service/server.') | format('<b>', '</b>') }}</li>
              <li>{{ lang._('Add %sAuthentications:%s Optional: Sometimes needed to authenticate to a Provider or Service.') | format('<b>', '</b>') }}</li>
              <li>{{ lang._('Add %sRegistrations:%s Optional: Needed if the Provider requires registration for the trunks.') | format('<b>', '</b>') }}</li>
            </ul>
            <p>{{ lang._('Please be aware that you need to %smanually%s add the required firewall rules for all configured services.') | format('<b>', '</b>') }}</p>
            <br/>
        </div>
    </div>

    <div id="subtab_sbc-transports-introduction" class="tab-pane fade">
        <div class="col-md-12">
            <h1>{{ lang._('Transports') }}</h1>
            <p>{{ lang._('The SBC needs to know what protocol (TCP or UDP) and bind address an endpoint will communicate.') }}</p>
            <ul>
              <li>{{ lang._('%sFQDN or IP:%s The IP address or fully-qualified domain name that should be used when communicating with your server.') | format('<b>', '</b>') }}</li>
              <li>{{ lang._('%sPort:%s The TCP or UDP port that should be used. If unset, the same port the client connected to will be used.') | format('<b>', '</b>') }}</li>
            </ul>
            <br/>
        </div>
    </div>

    <div id="subtab_sbc-aors-introduction" class="tab-pane fade">
        <div class="col-md-12">
            <h1>{{ lang._('Address of Record') }}</h1>
            <p>{{ lang._("SBC requires AORs so endpoints can be contacted") }}</p>
            <ul>
              <li>{{ lang._('%sBackend Pools:%s The HAProxy backend. Group the %spreviously added servers%s to build a server farm. All servers in a group usually deliver the same content. The Backend Pool cares for health monitoring and load distribution. A Backend Pool must also be configured if you only have a single server. The same Backend Pool may be used for multiple Public Services.') | format('<b>', '</b>', '<b>', '</b>') }}</li>
              <li>{{ lang._('%sPublic Services:%s The HAProxy frontend. The Public Service listens for client connections, optionally applies rules and forwards client request data to the selected Backend Pool for load balancing or proxying. Every Public Service needs to be connected to a %spreviously created Backend Pool%s.') | format('<b>', '</b>', '<b>', '</b>') }}</li>
            </ul>
            <br/>
        </div>
    </div>

    <div id="subtab_sbc-endpoints-introduction" class="tab-pane fade">
        <div class="col-md-12">
            <h1>{{ lang._('Endpoints') }}</h1>
            <p>{{ lang._("An Endpoints is a profile of a SIP phone or SIP service and provides numerous SIP functionality options device. You can not contact an endpoint without one or more AoR entry(ies)") }}</p>
            <ul>
              <li>{{ lang._('%sHealth Monitors:%s The HAProxy "health checks". Health Monitors are used by %sBackend Pools%s to determine if a server is still able to respond to client requests. If a server fails a health check it will automatically be removed from a Backend Pool and healthy servers are automatically re-added.') | format('<b>', '</b>', '<b>', '</b>') }}</li>
              <li>{{ lang._('%sConditions:%s HAProxy is capable of extracting data from requests, responses and other connection data and match it against predefined patterns. Use these powerful patterns to compose a condition that may be used in multiple Rules.') | format('<b>', '</b>') }}</li>
              <li>{{ lang._('%sRules:%s Perform a large set of actions if one or more %sConditions%s match. These Rules may be used in %sBackend Pools%s as well as %sPublic Services%s.') | format('<b>', '</b>', '<b>', '</b>', '<b>', '</b>', '<b>', '</b>') }}</li>
            </ul>
            <br/>
        </div>
    </div>

    <div id="subtab_sbc-authentications-introduction" class="tab-pane fade">
        <div class="col-md-12">
            <h1>{{ lang._('Authentications') }}</h1>
            <p>{{ lang._("Optionally HAProxy manages an internal list of users and groups, which can be used for HTTP Basic Authentication as well as access to HAProxy's internal statistic pages.") }}</p>
            <ul>
              <li>{{ lang._('%sUser:%s A username/password combination. Both secure (encrypted) and insecure (unencrypted) passwords can be used.') | format('<b>', '</b>') }}</li>
              <li>{{ lang._('%sGroup:%s A optional list containing one or more users. Groups usually make it easier to manage permissions for a large number of users') | format('<b>', '</b>') }}</li>
            </ul>
            <p>{{ lang._('Note that users and groups must be selected from the Backend Pool or Public Service configuration in order to be used for authentication. In addition to this users and groups may also be used in Rules/Conditions.') }}</p>
            <p>{{ lang._("For more information on HAProxy's %suser/group management%s see the %sofficial documentation%s.") | format('<b>', '</b>', '<a href="http://cbonte.github.io/haproxy-dconv/1.8/configuration.html#3.4" target="_blank">', '</a>') }}</p>
            <br/>
        </div>
    </div>

    <div id="subtab_sbc-registrations-introduction" class="tab-pane fade">
        <div class="col-md-12">
            <h1>{{ lang._('Registrations') }}</h1>
            <p>{{ lang._("Optionally HAProxy manages an internal list of users and groups, which can be used for HTTP Basic Authentication as well as access to HAProxy's internal statistic pages.") }}</p>
            <ul>
              <li>{{ lang._('%sUser:%s A username/password combination. Both secure (encrypted) and insecure (unencrypted) passwords can be used.') | format('<b>', '</b>') }}</li>
              <li>{{ lang._('%sGroup:%s A optional list containing one or more users. Groups usually make it easier to manage permissions for a large number of users') | format('<b>', '</b>') }}</li>
            </ul>
            <p>{{ lang._('Note that users and groups must be selected from the Backend Pool or Public Service configuration in order to be used for authentication. In addition to this users and groups may also be used in Rules/Conditions.') }}</p>
            <p>{{ lang._("For more information on HAProxy's %suser/group management%s see the %sofficial documentation%s.") | format('<b>', '</b>', '<a href="http://cbonte.github.io/haproxy-dconv/1.8/configuration.html#3.4" target="_blank">', '</a>') }}</p>
            <br/>
        </div>
    </div>

    <div id="subtab_sbc-codecs-introduction" class="tab-pane fade">
        <div class="col-md-12">
            <h1>{{ lang._('Codecs') }}</h1>
            <p>{{ lang._("Optionally HAProxy manages an internal list of users and groups, which can be used for HTTP Basic Authentication as well as access to HAProxy's internal statistic pages.") }}</p>
            <ul>
              <li>{{ lang._('%sUser:%s A username/password combination. Both secure (encrypted) and insecure (unencrypted) passwords can be used.') | format('<b>', '</b>') }}</li>
              <li>{{ lang._('%sGroup:%s A optional list containing one or more users. Groups usually make it easier to manage permissions for a large number of users') | format('<b>', '</b>') }}</li>
            </ul>
            <p>{{ lang._('Note that users and groups must be selected from the Backend Pool or Public Service configuration in order to be used for authentication. In addition to this users and groups may also be used in Rules/Conditions.') }}</p>
            <p>{{ lang._("For more information on HAProxy's %suser/group management%s see the %sofficial documentation%s.") | format('<b>', '</b>', '<a href="http://cbonte.github.io/haproxy-dconv/1.8/configuration.html#3.4" target="_blank">', '</a>') }}</p>
            <br/>
        </div>
    </div>

    {# add automatically generated tabs #}
    {% for tab in mainForm['tabs']|default([]) %}
        {% if tab['subtabs']|default(false) %}
            {# Tab with dropdown #}
            {% for subtab in tab['subtabs']|default({})%}
                <div id="subtab_{{subtab[0]}}" class="tab-pane fade{% if mainForm['activetab']|default("") == subtab[0] %} in active {% endif %}">
                    {{ partial("layout_partials/base_form",['fields':subtab[2],'id':'frm_'~subtab[0],'data_title':subtab[1],'apply_btn_id':'save_'~subtab[0]])}}
                </div>
            {% endfor %}
        {% endif %}
        {% if tab['subtabs']|default(false)==false %}
            <div id="tab_{{tab[0]}}" class="tab-pane fade{% if mainForm['activetab']|default("") == tab[0] %} in active {% endif %}">
                {{ partial("layout_partials/base_form",['fields':tab[2],'id':'frm_'~tab[0],'apply_btn_id':'save_'~tab[0]])}}
            </div>
        {% endif %}
    {% endfor %}

    <div id="transports" class="tab-pane fade">
        <!-- tab page "transports" -->
        <table id="grid-transports" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="DialogTransport">
            <thead>
            <tr>
                <th data-column-id="enabled" data-width="6em" data-type="string" data-formatter="rowtoggle">{{ lang._('Enabled') }}</th>
                <th data-column-id="name" data-type="string" data-visible="true">{{ lang._('Name') }}</th>
                <th data-column-id="description" data-type="string">{{ lang._('Description') }}</th>
                <th data-column-id="protocol" data-type="string" data-visible="true">{{ lang._('Protocol') }}</th>
                <th data-column-id="bindAddress" data-type="string" data-identifier="true" data-visible="true">{{ lang._('IP Address') }}</th>
                <th data-column-id="bindPort" data-type="string" data-identifier="true" data-visible="true">{{ lang._('Port') }}</th>
                <th data-column-id="uuid" data-type="string" data-identifier="true" data-visible="false">{{ lang._('ID') }}</th>
                <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
            </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
        <!-- apply button -->
        <div class="col-md-12">
            <hr/>
            <button class="btn btn-primary" id="reconfigureAct-transports" type="button"><b>{{ lang._('Apply') }}</b><i id="reconfigureAct_progress" class=""></i></button>
            <!-- button class="btn btn-primary" id="configtestAct-transports" type="button"><b>{{ lang._('Test syntax') }}</b><i id="configtestAct_progress" class=""></i></button -->
            <br/>
            <br/>
        </div>
    </div>

    <div id="aors" class="tab-pane fade">
        <!-- tab page "aors" -->
        <table id="grid-aors" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="DialogAoR">
            <thead>
            <tr>
                <th data-column-id="enabled" data-width="6em" data-type="string" data-formatter="rowtoggle">{{ lang._('Enabled') }}</th>
                <th data-column-id="name" data-type="string">{{ lang._('Name') }}</th>
                <th data-column-id="description" data-type="string">{{ lang._('Description') }}</th>
                <th data-column-id="contacts" data-type="string" data-identifier="true">{{ lang._('Static Contacts') }}</th>
                <th data-column-id="maxContacts" data-type="string" data-identifier="true">{{ lang._('Max Contacts') }}</th>
                <th data-column-id="outboundProxy" data-type="string" data-visible="false">{{ lang._('Outbound Proxy') }}</th>
                <th data-column-id="uuid" data-type="string" data-identifier="true" data-visible="false">{{ lang._('ID') }}</th>
                <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
             </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
        <!-- apply button -->
        <div class="col-md-12">
            <hr/>
            <button class="btn btn-primary" id="reconfigureAct-aors" type="button"><b>{{ lang._('Apply') }}</b><i id="reconfigureAct_progress" class=""></i></button>
            <!-- button class="btn btn-primary" id="configtestAct-aors" type="button"><b>{{ lang._('Test syntax') }}</b><i id="configtestAct_progress" class=""></i></button -->
            <br/>
            <br/>
        </div>
    </div>

    <div id="endpoints" class="tab-pane fade">
        <!-- tab page "endpoints" -->
        <table id="grid-endpoints" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="DialogEndpoint">
            <thead>
            <tr>
                <th data-column-id="enabled" data-width="6em" data-type="string" data-formatter="rowtoggle">{{ lang._('Enabled') }}</th>
                <th data-column-id="name" data-type="string">{{ lang._('Name') }}</th>
                <th data-column-id="description" data-type="string">{{ lang._('Description') }}</th>
                <th data-column-id="uuid" data-type="string" data-identifier="true" data-visible="false">{{ lang._('ID') }}</th>
                <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
            </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
        <!-- apply button -->
        <div class="col-md-12">
            <hr/>
            <button class="btn btn-primary" id="reconfigureAct-endpoints" type="button"><b>{{ lang._('Apply') }}</b><i id="reconfigureAct_progress" class=""></i></button>
            <!-- button class="btn btn-primary" id="configtestAct-endpoints" type="button"><b>{{ lang._('Test syntax') }}</b><i id="configtestAct_progress" class=""></i></button -->
            <br/>
            <br/>
        </div>
    </div>

    <div id="authentications" class="tab-pane fade">
        <!-- tab page "authentications" -->
        <table id="grid-authentications" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="DialogAuthentication">
            <thead>
            <tr>
                <th data-column-id="enabled" data-width="6em" data-type="string" data-formatter="rowtoggle">{{ lang._('Enabled') }}</th>
                <th data-column-id="name" data-type="string">{{ lang._('Name') }}</th>
                <th data-column-id="description" data-type="string">{{ lang._('Description') }}</th>
                <th data-column-id="uuid" data-type="string" data-identifier="true" data-visible="false">{{ lang._('ID') }}</th>
                <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
            </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
        <!-- apply button -->
        <div class="col-md-12">
            <hr/>
            <button class="btn btn-primary" id="reconfigureAct-authentications" type="button"><b>{{ lang._('Apply') }}</b><i id="reconfigureAct_progress" class=""></i></button>
            <!-- button class="btn btn-primary" id="configtestAct-authentications" type="button"><b>{{ lang._('Test syntax') }}</b><i id="configtestAct_progress" class=""></i></button -->
            <br/>
            <br/>
        </div>
    </div>

    <div id="registrations" class="tab-pane fade">
        <!-- tab page "registrations" -->
        <table id="grid-registrations" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="DialogRegistration">
            <thead>
            <tr>
                <th data-column-id="enabled" data-width="6em" data-type="string" data-formatter="rowtoggle">{{ lang._('Enabled') }}</th>
                <th data-column-id="name" data-type="string">{{ lang._('Name') }}</th>
                <th data-column-id="description" data-type="string">{{ lang._('Description') }}</th>
                <th data-column-id="uuid" data-type="string" data-identifier="true" data-visible="false">{{ lang._('ID') }}</th>
                <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
            </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
        <!-- apply button -->
        <div class="col-md-12">
            <hr/>
            <button class="btn btn-primary" id="reconfigureAct-registrations" type="button"><b>{{ lang._('Apply') }}</b><i id="reconfigureAct_progress" class=""></i></button>
            <!-- button class="btn btn-primary" id="configtestAct-registrations" type="button"><b>{{ lang._('Test syntax') }}</b><i id="configtestAct_progress" class=""></i></button -->
            <br/>
            <br/>
        </div>
    </div>

    <div id="codecs" class="tab-pane fade">
        <!-- tab page "codecs" -->
        <table id="grid-codecs" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="DialogCodec">
            <thead>
            <tr>
                <th data-column-id="enabled" data-width="6em" data-type="string" data-formatter="rowtoggle">{{ lang._('Enabled') }}</th>
                <th data-column-id="name" data-type="string">{{ lang._('Name') }}</th>
                <th data-column-id="description" data-type="string">{{ lang._('Description') }}</th>
                <th data-column-id="uuid" data-type="string" data-identifier="true" data-visible="false">{{ lang._('ID') }}</th>
                <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
            </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
        <!-- apply button -->
        <div class="col-md-12">
            <hr/>
            <!-- button class="btn btn-primary" id="reconfigureAct-codecs" type="button"><b>{{ lang._('Apply') }}</b><i id="reconfigureAct_progress" class=""></i></button -->
            <!-- button class="btn btn-primary" id="configtestAct-codecs" type="button"><b>{{ lang._('Test syntax') }}</b><i id="configtestAct_progress" class=""></i></button -->
            <br/>
            <br/>
        </div>
    </div>
</div>

{# include dialogs #}
{{ partial("layout_partials/base_dialog",['fields':formDialogTransport,'id':'DialogTransport','label':lang._('Edit Transport')])}}
{{ partial("layout_partials/base_dialog",['fields':formDialogAoR,'id':'DialogAoR','label':lang._('Edit AoR')])}}
{{ partial("layout_partials/base_dialog",['fields':formDialogEndpoint,'id':'DialogEndpoint','label':lang._('Edit Endpoint')])}}
{{ partial("layout_partials/base_dialog",['fields':formDialogAuthentication,'id':'DialogAuthentication','label':lang._('Edit Authentication')])}}
{{ partial("layout_partials/base_dialog",['fields':formDialogRegistration,'id':'DialogRegistration','label':lang._('Edit Registration')])}}
{{ partial("layout_partials/base_dialog",['fields':formDialogCodec,'id':'DialogCodec','label':lang._('Edit Codec')])}}
{{ partial("layout_partials/base_form",['fields':formGeneralSettings,'id':'frm_GeneralSettings'])}}
