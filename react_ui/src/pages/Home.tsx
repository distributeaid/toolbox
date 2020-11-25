import React, { useState } from 'react'
import { useMediaQuery } from 'react-responsive'

import { classnames } from '../components/classnames'
import { ContentContainer } from '../components/ContentContainer'

export const Home: React.FC = () => {
  const [selectedShipment, setSelectedShipment] = useState<Shipment | null>(
    null
  )

  const isMobile = useMediaQuery({ maxWidth: 768 })

  return (
    <>
      {isMobile && (
        <ContentContainer>
          <h1 className="font-bold text-3xl m-3">Shipments</h1>

          {FAKE_SHIPMENTS.map((shipment, i) => (
            <div
              key={`shipment-${i}`}
              className="shadow-md border border-gray-100 m-3 rounded text-xs">
              <div className="m-2 mb-0">{shipment.id}</div>

              <div className="text-base font-bold m-2">{shipment.manifest}</div>

              <hr />

              <div className="flex flex-row justify-between m-2">
                <div className="w-1/4">
                  <div className="font-bold">Status</div>
                  {shipment.status}
                </div>

                <div className="w-1/4">
                  <div className="font-bold">Next steps</div>
                </div>

                <div className="w-1/4">
                  <div className="font-bold">Pickup date</div>
                  {shipment.pickUpDate}
                </div>
              </div>

              <div className="flex flex-row justify-between m-2">
                <div className="w-1/4">
                  <div className="font-bold">Origin</div>
                  {shipment.originator}
                </div>

                <div className="w-1/4">
                  <div className="font-bold">Destination</div>
                  {shipment.destination}
                </div>

                <div className="w-1/4">
                  <div className="font-bold">Arrival date</div>
                  {shipment.arrivalDate}
                </div>
              </div>
            </div>
          ))}
        </ContentContainer>
      )}

      {!isMobile && (
        <ContentContainer>
          <div onClick={() => setSelectedShipment(null)}>
            <h1 className="font-bold text-3xl m-6">Shipments</h1>

            <table className="table-fixed m-6">
              <thead>
                <tr>
                  <th className="w-1/12 font-normal text-left py-2">ID</th>
                  <th className="w-1/12 font-normal text-left py-2">Status</th>
                  <th className="w-3/12 font-normal text-left py-2">
                    Manifest
                  </th>
                  <th className="w-1/12 font-normal text-left py-2">
                    Destination
                  </th>
                  <th className="w-1/12 font-normal text-left py-2">
                    Pickup date
                  </th>
                  <th className="w-1/12 font-normal text-left py-2">
                    Arrival date
                  </th>
                  <th className="w-1/12 font-normal text-left py-2">
                    Organized By
                  </th>
                </tr>
              </thead>

              <tbody>
                {FAKE_SHIPMENTS.map((shipment, i) => (
                  <tr
                    key={`shipment-${i}`}
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
      )}
    </>
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
