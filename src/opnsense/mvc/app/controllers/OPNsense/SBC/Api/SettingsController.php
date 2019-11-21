<?php
/**
 *    Copyright (C) 2016 Frank Wall
 *    Copyright (C) 2015 Deciso B.V.
 *
 *    All rights reserved.
 *
 *    Redistribution and use in source and binary forms, with or without
 *    modification, are permitted provided that the following conditions are met:
 *
 *    1. Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *
 *    2. Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 *    THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 *    AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *    AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 *    OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *    POSSIBILITY OF SUCH DAMAGE.
 *
 */
namespace OPNsense\SBC\Api;

use OPNsense\Base\ApiMutableModelControllerBase;
use \OPNsense\Base\UIModelGrid;
use \OPNsense\Core\Config;
use \OPNsense\SBC\SBC;

/**
 * Class SettingsController
 * @package OPNsense\SBC
 */
class SettingsController extends ApiMutableModelControllerBase
{
    protected static $internalModelName = 'sbc';
    protected static $internalModelClass = '\OPNsense\SBC\SBC';
    
    // Transport related API's
    public function getTransportAction($uuid = null)
    {
        return $this->getBase('transport', 'transports.transport', $uuid);
    }
    
    public function setTransportAction($uuid)
    {
        return $this->setBase('transport', 'transports.transport', $uuid);
    }
    
    public function addTransportAction()
    {
        return $this->addBase('transport', 'transports.transport');
    }
    
    public function delTransportAction($uuid)
    {
        return $this->delBase('transports.transport', $uuid);
    }
    
    public function toggleTransportAction($uuid)
    {
        return $this->toggleBase('transports.transport', $uuid);
    }
    
    public function searchTransportsAction()
    {
        $filter_funct = function ($record) {
            if ($record->bindPort == "") {
                $record->bindPort = "5060 (Default)";
            }
            return true;
        };
        return $this->searchBase('transports.transport', array('enabled', 'name', 'description', 'protocol', 'bindAddress', 'bindPort'), 'name', $filter_funct);
    }

    // AoR Related API's
    public function getAoRAction($uuid = null)
    {
        return $this->getBase('aor', 'aors.aor', $uuid);
    }
    
    public function setAorAction($uuid)
    {
        return $this->setBase('aor', 'aors.aor', $uuid);
    }
    
    public function addAoRAction()
    {
        return $this->addBase('aor', 'aors.aor');
    }
    
    public function delAoRAction($uuid)
    {
        return $this->delBase('aors.aor', $uuid);
    }
    
    public function toggleAoRAction($uuid, $enabled = null)
    {
        return $this->toggleBase('aors.aor', $uuid);
    }
    
    public function searchAoRsAction()
    {
        $filter_funct = function ($record) {
            if ($record->contacts == "") {
                $record->contacts = "None (Default)";
            }
            if ($record->maxContacts == "") {
                $record->maxContacts = "0 (Default)";
            }
            return true;
        };
        return $this->searchBase('aors.aor', array('enabled', 'name', 'description', 'contacts', 'maxContacts'), 'name', $filter_funct);
    }

    // Endpoint Related API's
    public function getEndpointAction($uuid = null)
    {
        return $this->getBase('endpoint', 'endpoints.endpoint', $uuid);
    }
    
    public function setEndpointAction($uuid)
    {
        return $this->setBase('endpoint', 'endpoints.endpoint', $uuid);
    }
    
    public function addEndpointAction()
    {
        return $this->addBase('endpoint', 'endpoints.endpoint');
    }
    
    public function delEndpointAction($uuid)
    {
        return $this->delBase('endpoints.endpoint', $uuid);
    }
    
    public function toggleEndpointAction($uuid, $enabled = null)
    {
        return $this->toggleBase('endpoints.endpoint', $uuid);
    }
    
    public function searchEndpointsAction()
    {
        return $this->searchBase('endpoints.endpoint', array('enabled', 'name', 'description'), 'name');
    }


    // Identify Related API's
    public function getIdentityAction($uuid = null)
    {
        return $this->getBase('identity', 'identities.identity', $uuid);
    }

    public function setIdentityAction($uuid)
    {
        return $this->setBase('identity', 'identities.identity', $uuid);
    }

    public function addIdentityAction()
    {
        return $this->addBase('identity', 'identities.identity');
    }

    public function delIdentityAction($uuid)
    {
        return $this->delBase('identities.identity', $uuid);
    }

    public function toggleIdentityAction($uuid, $enabled = null)
    {
        return $this->toggleBase('identities.identity', $uuid);
    }

    public function searchIdentitiesAction()
    {
        return $this->searchBase('identities.identity', array('enabled', 'name', 'description'), 'name');
    }

    
    // Authentication Related API's
    public function getAuthenticationAction($uuid = null)
    {
        return $this->getBase('authentication', 'authentications.authentication', $uuid);
    }
    
    public function setAuthenticationAction($uuid)
    {
        return $this->setBase('authentication', 'authentications.authentication', $uuid);
    }
    
    public function addAuthenticationAction()
    {
        return $this->addBase('authentication', 'authentications.authentication');
    }
    
    public function delAuthenticationAction($uuid)
    {
        return $this->delBase('authentications.authentication', $uuid);
    }
    
    public function searchAuthenticationsAction()
    {
        return $this->searchBase('authentications.authentication', array('name', 'description'), 'name');
    }

    // Registration Related API's
    public function getRegistrationAction($uuid = null)
    {
        return $this->getBase('registration', 'registrations.registration', $uuid);
    }
    
    public function setRegistrationAction($uuid)
    {
        return $this->setBase('registration', 'registrations.registration', $uuid);
    }
    
    public function addRegistrationAction()
    {
        return $this->addBase('registration', 'registrations.registration');
    }
    
    public function delRegistrationAction($uuid)
    {
        return $this->delBase('registrations.registration', $uuid);
    }
    
    public function searchRegistrationsAction()
    {
        return $this->searchBase('registrations.registration', array('name', 'description'), 'name');
    }

    // Codec Related API's
    public function getCodecAction($uuid = null)
    {
        return $this->getBase('codec', 'codecs.codec', $uuid);
    }
    
    public function setCodecAction($uuid)
    {
        return $this->setBase('codec', 'codecs.codec', $uuid);
    }
    
    public function addCodecAction()
    {
        return $this->addBase('codec', 'codecs.codec');
    }
    
    public function delCodecAction($uuid)
    {
        return $this->delBase('codecs.codec', $uuid);
    }
    
    public function searchCodecsAction()
    {
        return $this->searchBase('codecs.codec', array('name', 'description'), 'name');
    }
}
