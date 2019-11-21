<?php
/**
 *    Copyright (C) 2018 KSA Technologies, LLC
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
namespace OPNsense\SBC;

use OPNsense\Base\BaseModel;

class SBC extends BaseModel
{
    /**
     * create a new Transport
     * @param string $name
     * @param string $description
     * @param string $expression
     * @param string $negate
     * @param hash $parameters
     * @return string
     */
    public function newTransport($name, $description = "", $protocol = "udp", $bindaddr = "0.0.0.0")
    {
        $transport = $this->transports->transport->Add();
        $uuid = $transport->getAttributes()['uuid'];
        $transport->name = $name;
        $transport->description = $description;
        $transport->protocol = $protocol;
        $transport->bindaddr = $bindaddr;
        return $uuid;
    }
    
    /**
     * create a new action
     * @param string $name
     * @param string $description
     * @param string $testType
     * @param string $linkedAcls
     * @param string $operator
     * @param string $type
     * @param string $useBackend
     * @param string $useServer
     * @param string $actionName
     * @param string $actionFind
     * @param string $actionValue
     * @return string
     */
    public function newAoR($name, $description = "", $contact = "None", $maxcontacts = "0")
    {
        $aor = $this->aors->aor->Add();
        $uuid = $aor->getAttributes()['uuid'];
        $aor->name = $name;
        $aor->description = $description;
        $aor->contact = $contact;
        $aor->maxcontacts = $maxcontacts;
        return $uuid;
    }

    /**
     * create a new server
     * @param string $name
     * @param string $description
     * @param string $address
     * @param string $port
     * @param string $mode
     * @param string $ssl
     * @param string $sslVerify
     * @param string $weight
     * @return string
     */
    public function newEndpoint($name, $description = "", $transport = "", $aors = "")
    {
        $endpoint = $this->endpoints->endpoint->Add();
        $uuid = $endpoint->getAttributes()['uuid'];
        $endpoint->name = $name;
        $endpoint->description = $description;
        $endpoint->transport = $transport;
        $endpoint->aors = $aors;
        return $uuid;
    }

    public function newIdentity($name, $description = "", $endpoint = "None", $matchList = "")
    {
        $identity = $this->identities->identity->Add();
        $uuid = $identity->getAttributes()['uuid'];
        $identity->name = $name;
        $identity->description = $description;
        $identity->endpoint = $endpoint;
        $identity->matchList = $matchList;
        return $uuid;
    }

    public function newCodec($name, $description = "")
    {
        $codec = $this->codecs->codec->Add();
        $uuid = $codec->getAttributes()['uuid'];
        $codec->name = $name;
        $codec->description = $description;
        return $uuid;
    }
}
