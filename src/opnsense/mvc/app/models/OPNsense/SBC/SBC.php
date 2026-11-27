<?php

/*
 * Copyright (C) 2026 KSA Technologies, LLC
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

namespace OPNsense\SBC;

use OPNsense\Base\BaseModel;
use OPNsense\Base\Messages\Message;

/**
 * Session Border Controller settings (PRD-SBC-0001).
 */
class SBC extends BaseModel
{
    /**
     * Cross-field checks the field types cannot express on their own.
     */
    public function performValidation($validateFullModel = false)
    {
        $messages = parent::performValidation($validateFullModel);
        $general = $this->general;

        if (
            ($validateFullModel || $general->rtp_port_min->isFieldChanged() || $general->rtp_port_max->isFieldChanged()) &&
            (int)(string)$general->rtp_port_min >= (int)(string)$general->rtp_port_max
        ) {
            $messages->appendMessage(new Message(
                gettext('The first media port must be lower than the last.'),
                $general->rtp_port_min->__reference
            ));
        }

        if (
            ($validateFullModel || $general->external_interface->isFieldChanged() ||
                $general->internal_interface->isFieldChanged()) &&
            (string)$general->external_interface === (string)$general->internal_interface
        ) {
            $messages->appendMessage(new Message(
                gettext('The external and internal interfaces must be different.'),
                $general->internal_interface->__reference
            ));
        }

        return $messages;
    }
}
