/*
Icons
================================================================================
Fine-grained icon management.  Only load what we use.

See: https://fontawesome.com/how-to-use/with-the-api/setup/getting-started
*/
import { config, dom, library } from "@fortawesome/fontawesome-svg-core";
import {
  faBoxes,
  faCheck,
  faCode,
  faEuroSign,
  faEye,
  faHome,
  faList,
  faLock,
  faMapMarkerAlt,
  faPaperPlane,
  faPencilAlt,
  faPlus,
  faPlusCircle,
  faQuestion,
  faTrashAlt,
  faTruck,
  faUnlock,
  faUnlockAlt,
  faUserCircle,
  faUsers
} from "@fortawesome/free-solid-svg-icons";

// There are different defaults for the svg-core loaded FontAwesome and the
// normal (full) FontAwesome.  We want the normal functionality.
//
// See: https://fontawesome.com/how-to-use/with-the-api/setup/configuration
config.autoReplaceSvg = true;
config.observeMutations = true; 

library.add(
  faBoxes,
  faCheck,
  faCode,
  faEuroSign,
  faEye,
  faHome,
  faList,
  faLock,
  faMapMarkerAlt,
  faPaperPlane,
  faPencilAlt,
  faPlus,
  faPlusCircle,
  faQuestion,
  faTrashAlt,
  faTruck,
  faUnlock,
  faUnlockAlt,
  faUserCircle,
  faUsers
);

dom.watch();
