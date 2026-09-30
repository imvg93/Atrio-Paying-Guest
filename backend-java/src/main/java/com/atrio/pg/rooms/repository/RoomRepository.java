package com.atrio.pg.rooms.repository;

import com.atrio.pg.rooms.domain.Room;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RoomRepository extends JpaRepository<Room, UUID> {

    List<Room> findAllByPropertyId(UUID propertyId);

    boolean existsByPropertyIdAndRoomNumber(UUID propertyId, String roomNumber);
}
