import React, { useState } from 'react'

import { classnames } from '../components/classnames'
import { ContentContainer } from '../components/ContentContainer'

export const Home: React.FC = () => {
  const [selectedShipment, setSelectedShipment] = useState<Shipment | null>(
    null
  )

  return (
    <ContentContainer>
      <div onClick={() => setSelectedShipment(null)}>
        <h1 className="font-bold text-3xl m-6">Shipments</h1>

        <table className="table-fixed m-6">
          <thead>
            <tr>
              <th className="w-1/12 font-normal text-left py-2">ID</th>
              <th className="w-1/12 font-normal text-left py-2">Status</th>
              <th className="w-3/12 font-normal text-left py-2">Manifest</th>
              <th className="w-1/12 font-normal text-left py-2">Destination</th>
              <th className="w-1/12 font-normal text-left py-2">Pickup date</th>
              <th className="w-1/12 font-normal text-left py-2">
                Arrival date
              </th>
              <th className="w-1/12 font-normal text-left py-2">
                Organized By
              </th>
            </tr>
          </thead>

          <tbody>
            {FAKE_SHIPMENTS.map((shipment) => (
              <tr
                className="border-t hover:bg-gray-100 cursor-pointer"
                onClick={(e) => {
                  e.stopPropagation()
                  setSelectedShipment(shipment)
                }}>
                <td className="py-2">{shipment.id}</td>
                <td className="py-2">{shipment.status}</td>
                <td className="py-2">{shipment.manifest}</td>
                <td className="py-2">{shipment.destination}</td>
                <td className="py-2">{shipment.pickUpDate}</td>
                <td className="py-2">{shipment.arrivalDate}</td>
                <td className="py-2">{shipment.originator}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div
        className={classnames(
          'sidebar z-40 p-6',
          !!selectedShipment && 'sidebar--open',
          'sidebar--closed' && !selectedShipment
        )}>
        <SidebarContents shipment={selectedShipment} />
      </div>
    </ContentContainer>
  )
}

type SidebarContentsProps = {
  shipment: Shipment | null
}

const SidebarContents: React.FC<SidebarContentsProps> = ({
  shipment,
}: SidebarContentsProps) => {
  if (shipment == null) {
    return null
  }

  return (
    <div>
      <div>Manifest</div>

      <h2 className="text-3xl my-3">{shipment.manifest}</h2>

      {shipment.id}
    </div>
  )
}

type Shipment = {
  id: string
  status: string
  manifest: string
  destination: string
  pickUpDate: string
  arrivalDate: string
  originator: string
}

const FAKE_SHIPMENTS: Array<Shipment> = [
  {
    id: 'AB-12345',
    status: 'PLANNING',
    manifest: 'Winter Aid',
    destination: 'Moria',
    pickUpDate: '01-01-2021',
    arrivalDate: '02-01-2021',
    originator: 'Distribute Aid Partner',
  },
  {
    id: 'CD-67890',
    status: 'COMPLETED',
    manifest: 'Winter Aid',
    destination: 'Moria',
    pickUpDate: '01-01-2021',
    arrivalDate: '02-01-2021',
    originator: 'Distribute Aid Partner',
  },
  {
    id: 'EF-12345',
    status: 'PLANNING',
    manifest: 'Winter Aid',
    destination: 'Moria',
    pickUpDate: '01-01-2021',
    arrivalDate: '02-01-2021',
    originator: 'Distribute Aid Partner',
  },
  {
    id: 'GH-12345',
    status: 'IN_PROGRESS',
    manifest: 'Winter Aid',
    destination: 'Moria',
    pickUpDate: '01-01-2021',
    arrivalDate: '02-01-2021',
    originator: 'Distribute Aid Partner',
  },
  {
    id: 'IJ-12345',
    status: 'PLANNING',
    manifest: 'Winter Aid',
    destination: 'Moria',
    pickUpDate: '01-01-2021',
    arrivalDate: '02-01-2021',
    originator: 'Distribute Aid Partner',
  },
]
